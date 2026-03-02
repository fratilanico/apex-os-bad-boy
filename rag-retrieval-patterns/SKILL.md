---
name: rag-retrieval-patterns
description: "Use when building or debugging RAG pipelines, when semantic search returns irrelevant results, when implementing hybrid BM25+dense retrieval, or when grounding LLM answers in document sources. Triggers on: retrieval augmented generation, vector search, embeddings, BM25, reranking, knowledge base."
tier: FULL
tags: [rag, retrieval, embeddings, vector-search, bm25, supabase, apex-os]
source: HandsOnLLM Ch.8
last-updated: 2026-02-27
---

# RAG & Retrieval Patterns — APEX OS Standard

## Overview

From HandsOnLLM Ch.8. Dense vs sparse retrieval, hybrid pipelines, reranking.
APEX OS skills engine uses `text-embedding-3-small` on Azure + Supabase pgvector.

## Retrieval Strategy Decision Tree

```
┌────────────────────────────────────────────────────────────────────────┐
│ Query type?                                                             │
├────────────────────────────────────────────────────────────────────────┤
│ Keyword / exact match / product codes  → BM25 (sparse)                 │
│ Semantic / meaning / concepts          → Dense (embeddings)            │
│ Mixed / production / best quality      → HYBRID (BM25 + dense + rerank)│
└────────────────────────────────────────────────────────────────────────┘
```

## The 3 Retrieval Methods

### 1. Dense Retrieval (Embeddings)
```python
# APEX OS: Azure text-embedding-3-small + Supabase pgvector
from openai import AzureOpenAI

client = AzureOpenAI(
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
    api_key=os.environ["AZURE_OPENAI_API_KEY"],
    api_version="2024-02-01"
)

def embed(text: str, input_type: str = "query") -> list[float]:
    # CRITICAL: separate input_type for query vs document
    # query → retrieval.query
    # document → retrieval.passage
    response = client.embeddings.create(
        input=text,
        model="text-embedding-3-small",
        extra_body={"input_type": input_type}
    )
    return response.data[0].embedding

# Supabase pgvector similarity search
results = supabase.rpc("match_skills", {
    "query_embedding": embed(query, "query"),
    "match_threshold": 0.7,
    "match_count": 10
}).execute()
```

### 2. BM25 (Sparse / Keyword)
```python
from rank_bm25 import BM25Okapi

corpus = [doc.split() for doc in documents]
bm25 = BM25Okapi(corpus)
scores = bm25.get_scores(query.split())
top_idx = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:10]
```

### 3. Hybrid Pipeline (Production Standard)
```python
def hybrid_retrieve(query: str, documents: list[str], top_k: int = 5):
    # Step 1: Dense retrieval (semantic)
    dense_results = dense_search(query, documents, top_k=20)

    # Step 2: BM25 (keyword)
    sparse_results = bm25_search(query, documents, top_k=20)

    # Step 3: Reciprocal Rank Fusion
    scores = {}
    for rank, doc in enumerate(dense_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (60 + rank)
    for rank, doc in enumerate(sparse_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (60 + rank)

    # Step 4: Rerank with cross-encoder
    candidates = sorted(scores, key=scores.get, reverse=True)[:20]
    return rerank(query, candidates)[:top_k]
```

## Supabase pgvector Setup (APEX OS)

```sql
-- Enable extension
create extension if not exists vector;

-- Table with embedding column
create table skill_registry (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    embedding vector(1536),  -- text-embedding-3-small dimension
    created_at timestamptz default now()
);

-- HNSW index (faster than ivfflat for < 1M rows)
create index on skill_registry
using hnsw (embedding vector_cosine_ops);

-- Match function
create or replace function match_skills(
    query_embedding vector(1536),
    match_threshold float,
    match_count int
)
returns table (id uuid, name text, description text, similarity float)
language sql stable as $$
    select id, name, description,
           1 - (embedding <=> query_embedding) as similarity
    from skill_registry
    where 1 - (embedding <=> query_embedding) > match_threshold
    order by embedding <=> query_embedding
    limit match_count;
$$;
```

## RAG Grounded Generation

```python
def rag_answer(query: str) -> str:
    # 1. Retrieve
    docs = hybrid_retrieve(query, top_k=5)

    # 2. Build grounded prompt
    context = "\n\n".join(f"[{i+1}] {d.content}" for i, d in enumerate(docs))

    prompt = f"""Answer using ONLY the context below. If the answer is not in
the context, say "I don't have that information."

Context:
{context}

Question: {query}

Cite sources as [1], [2], etc."""

    # 3. Generate
    return llm.complete(prompt)
```

## Critical: input_type Separation

```
┌──────────────────────────────────┬────────────────────────────────────┐
│ Wrong (same type for both)        │ Right (separate types)             │
├──────────────────────────────────┼────────────────────────────────────┤
│ embed(query, "document")          │ embed(query, "query")              │
│ embed(document, "document")       │ embed(document, "passage")         │
│ → retrieval quality degrades 15%  │ → optimal similarity alignment     │
└──────────────────────────────────┴────────────────────────────────────┘
```

## Common Mistakes

- Using dense-only retrieval for keyword queries — BM25 beats it on exact matches
- Not reranking after fusion — raw scores from two systems don't compare directly
- Wrong `input_type` — query and passage embeddings must use their respective types
- Embedding entire documents — chunk first (512 tokens max), embed chunks
