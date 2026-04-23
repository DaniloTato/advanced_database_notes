# VECTOR SEARCH

## My understanding
Vector search is a way to find information based on meaning instead of exact words.

It works by converting text into numerical representations called embeddings (vectors). Then, instead of matching text directly, it compares how close two vectors are in space.

If two pieces of text have similar meaning, their vectors will be close—even if they use completely different words.

## Why it matters
Vector search is important because real-world language is messy.
People don’t always use the same words to describe the same thing. Traditional keyword search would fail in cases like:
- “car” vs “vehicle”
- “error” vs “bug”
- “buy” vs “purchase”
Vector search solves this by understanding context and meaning.

## Example

```SQL
SELECT
    chunk_id,
    chunk_text,
    VECTOR_DISTANCE(chunk_vector, query_vector, COSINE) AS distance
FROM doc_chunks
ORDER BY distance ASC
FETCH FIRST 3 ROWS ONLY;
```