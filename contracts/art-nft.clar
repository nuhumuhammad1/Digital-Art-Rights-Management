;; Art NFT Contract

(define-non-fungible-token art-nft uint)

(define-map art-nft-data
  { token-id: uint }
  {
    owner: principal,
    title: (string-ascii 100),
    description: (string-utf8 500),
    license-terms: (string-utf8 1000)
  }
)

(define-data-var token-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-last-token-id)
  (ok (var-get token-id-nonce))
)

(define-read-only (get-token-uri (token-id uint))
  (ok none)
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? art-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (nft-transfer? art-nft token-id sender recipient)
  )
)

(define-public (mint-art-nft (title (string-ascii 100)) (description (string-utf8 500)) (license-terms (string-utf8 1000)))
  (let
    ((new-token-id (+ (var-get token-id-nonce) u1)))
    (asserts! (is-none (nft-get-owner? art-nft new-token-id)) ERR_ALREADY_EXISTS)
    (try! (nft-mint? art-nft new-token-id tx-sender))
    (map-set art-nft-data
      { token-id: new-token-id }
      {
        owner: tx-sender,
        title: title,
        description: description,
        license-terms: license-terms
      }
    )
    (var-set token-id-nonce new-token-id)
    (ok new-token-id)
  )
)

(define-read-only (get-art-nft-data (token-id uint))
  (map-get? art-nft-data { token-id: token-id })
)

(define-public (update-license-terms (token-id uint) (new-license-terms (string-utf8 1000)))
  (let
    ((nft-data (unwrap! (map-get? art-nft-data { token-id: token-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner nft-data)) ERR_UNAUTHORIZED)
    (ok (map-set art-nft-data
      { token-id: token-id }
      (merge nft-data { license-terms: new-license-terms })
    ))
  )
)

