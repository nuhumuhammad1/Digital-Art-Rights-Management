;; Energy NFT Contract

(define-non-fungible-token energy-nft uint)

(define-map energy-nft-data
  { token-id: uint }
  {
    owner: principal,
    energy-type: (string-ascii 20),
    value: uint,
    timestamp: uint
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
  (ok (nft-get-owner? energy-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (nft-transfer? energy-nft token-id sender recipient)
  )
)

(define-public (mint-energy-nft (energy-type (string-ascii 20)) (value uint))
  (let
    ((new-token-id (+ (var-get token-id-nonce) u1)))
    (asserts! (is-none (nft-get-owner? energy-nft new-token-id)) ERR_ALREADY_EXISTS)
    (try! (nft-mint? energy-nft new-token-id tx-sender))
    (map-set energy-nft-data
      { token-id: new-token-id }
      {
        owner: tx-sender,
        energy-type: energy-type,
        value: value,
        timestamp: block-height
      }
    )
    (var-set token-id-nonce new-token-id)
    (ok new-token-id)
  )
)

(define-read-only (get-energy-nft-data (token-id uint))
  (map-get? energy-nft-data { token-id: token-id })
)

