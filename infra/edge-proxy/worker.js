// Podcasterium edge proxy.
//
// Phase 1 shares its backend with DOMOVINA.ai (docs/06-backend-and-corpus.md
// §1). This Worker gives every backend host a podcasterium.com name, so the
// app never talks to a *.domovina.ai address: each request is forwarded
// unchanged (method, headers, body, WebSocket upgrades) to the matching
// upstream host. The CDN is not proxied here; cdn.podcasterium.com is a
// custom domain on the same R2 bucket.

const UPSTREAM = {
  'api.podcasterium.com': 'api.domovina.ai', // Supabase (auth, REST, functions, realtime)
  'mcp.podcasterium.com': 'mcp.domovina.ai', // RAG: semantic search, person hub
  'search.podcasterium.com': 'search.domovina.ai', // Meilisearch
  'cutter.podcasterium.com': 'cutter.domovina.ai', // clip cutter
};

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const upstream = UPSTREAM[url.hostname];
    if (!upstream) return new Response('Not found', { status: 404 });
    url.hostname = upstream;
    return fetch(new Request(url, request));
  },
};
