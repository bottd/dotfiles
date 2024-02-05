(fn quickf []
  (let [
    handle (io.popen "echo hello")
    result (handle:read :*a)
  ]
    (handle.close)
    (print result)
  )
)

(quickf)
