// Gives every backend host a podcasterium.com name. Phase 1 runs on a
// shared upstream backend (docs/06-backend-and-corpus.md §1); each request
// is forwarded unchanged (method, headers, body, WebSocket upgrades) to the
// same subdomain of the upstream zone. The zone is the Worker secret
// UPSTREAM_ZONE, not part of this repository.

// api: Supabase (auth, REST, functions, realtime) · mcp: semantic search and
// person pages · search: Meilisearch · cutter: clip cutter.
const PROXIED = new Set(['api', 'mcp', 'search', 'cutter']);

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const [sub, ...rest] = url.hostname.split('.');
    if (!PROXIED.has(sub) || rest.join('.') !== 'podcasterium.com' || !env.UPSTREAM_ZONE) {
      return new Response('Not found', { status: 404 });
    }
    url.hostname = `${sub}.${env.UPSTREAM_ZONE}`;
    return fetch(new Request(url, request));
  },
};
