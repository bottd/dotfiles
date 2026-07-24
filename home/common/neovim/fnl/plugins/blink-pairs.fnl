(local pairs (require :blink.pairs))

; v0.6+ needs the native lib present before setup; no-ops once downloaded
(: (pairs.download) :pwait 60000)

(pairs.setup {})
