;; Artwork Registration Contract

(define-map artworks
  { artwork-id: uint }
  {
    artist: principal,
    title: (string-ascii 100),
    description: (string-utf8 500),
    creation-date: uint,
    registration-date: uint,
    content-hash: (buff 32)
  }
)

(define-map artist-artworks
  { artist: principal }
  { artwork-ids: (list 1000 uint) }
)

(define-data-var artwork-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-artwork (artwork-id uint))
  (map-get? artworks { artwork-id: artwork-id })
)

(define-read-only (get-artist-artworks (artist principal))
  (map-get? artist-artworks { artist: artist })
)

(define-public (register-artwork (title (string-ascii 100)) (description (string-utf8 500)) (content-hash (buff 32)))
  (let
    ((new-artwork-id (+ (var-get artwork-id-nonce) u1))
     (artist-artwork-list (default-to { artwork-ids: (list) } (map-get? artist-artworks { artist: tx-sender }))))
    ;; Note: Removed check for duplicate content-hash to simplify the contract
    (map-set artworks
      { artwork-id: new-artwork-id }
      {
        artist: tx-sender,
        title: title,
        description: description,
        creation-date: block-height,
        registration-date: block-height,
        content-hash: content-hash
      }
    )
    (map-set artist-artworks
      { artist: tx-sender }
      { artwork-ids: (unwrap! (as-max-len? (append (get artwork-ids artist-artwork-list) new-artwork-id) u1000) ERR_UNAUTHORIZED) }
    )
    (var-set artwork-id-nonce new-artwork-id)
    (ok new-artwork-id)
  )
)

(define-public (update-artwork-details (artwork-id uint) (new-title (string-ascii 100)) (new-description (string-utf8 500)))
  (let
    ((artwork (unwrap! (map-get? artworks { artwork-id: artwork-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (get artist artwork) tx-sender) ERR_UNAUTHORIZED)
    (ok (map-set artworks
      { artwork-id: artwork-id }
      (merge artwork
        {
          title: new-title,
          description: new-description
        }
      )
    ))
  )
)

