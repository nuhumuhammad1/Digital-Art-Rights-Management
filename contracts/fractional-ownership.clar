;; Fractional Ownership Contract

(define-fungible-token art-share)

(define-map artwork-shares
  { artwork-id: uint }
  {
    total-shares: uint,
    available-shares: uint,
    share-price: uint
  }
)

(define-map user-shares
  { user: principal, artwork-id: uint }
  { shares: uint }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INSUFFICIENT_SHARES (err u401))

(define-read-only (get-artwork-shares (artwork-id uint))
  (map-get? artwork-shares { artwork-id: artwork-id })
)

(define-read-only (get-user-shares (user principal) (artwork-id uint))
  (default-to { shares: u0 } (map-get? user-shares { user: user, artwork-id: artwork-id }))
)

(define-public (create-shares (artwork-id uint) (total-shares uint) (share-price uint))
  (let
    ((artwork (unwrap! (contract-call? .artwork-registration get-artwork artwork-id) ERR_NOT_FOUND)))
    (asserts! (is-eq (get artist artwork) tx-sender) ERR_UNAUTHORIZED)
    (try! (ft-mint? art-share total-shares tx-sender))
    (map-set artwork-shares
      { artwork-id: artwork-id }
      {
        total-shares: total-shares,
        available-shares: total-shares,
        share-price: share-price
      }
    )
    (ok true)
  )
)

(define-public (buy-shares (artwork-id uint) (shares uint))
  (let
    ((artwork-share-info (unwrap! (map-get? artwork-shares { artwork-id: artwork-id }) ERR_NOT_FOUND))
     (total-cost (* shares (get share-price artwork-share-info))))
    (asserts! (<= shares (get available-shares artwork-share-info)) ERR_INSUFFICIENT_SHARES)
    (try! (stx-transfer? total-cost tx-sender (get artist (unwrap! (contract-call? .artwork-registration get-artwork artwork-id) ERR_NOT_FOUND))))
    (try! (ft-transfer? art-share shares (get artist (unwrap! (contract-call? .artwork-registration get-artwork artwork-id) ERR_NOT_FOUND)) tx-sender))
    (map-set artwork-shares
      { artwork-id: artwork-id }
      (merge artwork-share-info { available-shares: (- (get available-shares artwork-share-info) shares) })
    )
    (map-set user-shares
      { user: tx-sender, artwork-id: artwork-id }
      { shares: (+ shares (get shares (get-user-shares tx-sender artwork-id))) }
    )
    (ok true)
  )
)

(define-public (transfer-shares (artwork-id uint) (recipient principal) (shares uint))
  (let
    ((sender-shares (get shares (get-user-shares tx-sender artwork-id))))
    (asserts! (>= sender-shares shares) ERR_INSUFFICIENT_SHARES)
    (try! (ft-transfer? art-share shares tx-sender recipient))
    (map-set user-shares
      { user: tx-sender, artwork-id: artwork-id }
      { shares: (- sender-shares shares) }
    )
    (map-set user-shares
      { user: recipient, artwork-id: artwork-id }
      { shares: (+ shares (get shares (get-user-shares recipient artwork-id))) }
    )
    (ok true)
  )
)

