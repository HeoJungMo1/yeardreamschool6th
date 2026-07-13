SELECT 'albums'         AS table_name, COUNT(*) AS cnt FROM albums
UNION ALL SELECT 'artists',        COUNT(*) FROM artists
UNION ALL SELECT 'customers',      COUNT(*) FROM customers
UNION ALL SELECT 'employees',      COUNT(*) FROM employees
UNION ALL SELECT 'genres',         COUNT(*) FROM genres
UNION ALL SELECT 'invoices',       COUNT(*) FROM invoices
UNION ALL SELECT 'invoice_items',  COUNT(*) FROM invoice_items
UNION ALL SELECT 'media_types',    COUNT(*) FROM media_types
UNION ALL SELECT 'playlists',      COUNT(*) FROM playlists
UNION ALL SELECT 'playlist_track', COUNT(*) FROM playlist_track
UNION ALL SELECT 'tracks',         COUNT(*) FROM tracks;