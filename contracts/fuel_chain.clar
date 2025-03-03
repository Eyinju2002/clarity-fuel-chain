;; FuelChain Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-batch (err u101))
(define-constant err-unauthorized (err u102))

;; Data structures
(define-map batches uint 
  {
    quantity: uint,
    fuel-type: (string-ascii 20),
    certification: (string-ascii 32),
    owner: principal,
    created-at: uint
  }
)

(define-map batch-history uint (list 200 
  {
    action: (string-ascii 20),
    from: principal,
    to: principal,
    timestamp: uint
  }
))

(define-data-var batch-nonce uint u0)

;; SIP-010 Fungible Token
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-fungible-token fuel-token)

;; Public functions
(define-public (create-batch (quantity uint) (fuel-type (string-ascii 20)) (certification (string-ascii 32)))
  (let
    (
      (batch-id (+ (var-get batch-nonce) u1))
      (current-time (unwrap-panic (get-block-info? time u0)))
    )
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set batches batch-id
          {
            quantity: quantity,
            fuel-type: fuel-type,
            certification: certification,
            owner: contract-owner,
            created-at: current-time
          }
        )
        (map-set batch-history batch-id (list 
          {
            action: "created",
            from: contract-owner,
            to: contract-owner,
            timestamp: current-time
          }
        ))
        (var-set batch-nonce batch-id)
        (try! (ft-mint? fuel-token quantity contract-owner))
        (ok batch-id)
      )
      err-owner-only
    )
  )
)

(define-public (transfer-batch (batch-id uint) (recipient principal))
  (let
    (
      (batch (unwrap! (map-get? batches batch-id) err-invalid-batch))
      (current-time (unwrap-panic (get-block-info? time u0)))
    )
    (if (is-eq (get owner batch) tx-sender)
      (begin
        (try! (ft-transfer? fuel-token (get quantity batch) tx-sender recipient))
        (map-set batches batch-id (merge batch { owner: recipient }))
        (map-set batch-history batch-id 
          (append (default-to (list) (map-get? batch-history batch-id))
            {
              action: "transferred",
              from: tx-sender,
              to: recipient,
              timestamp: current-time
            }
          )
        )
        (ok true)
      )
      err-unauthorized
    )
  )
)

;; Read-only functions
(define-read-only (get-batch-details (batch-id uint))
  (ok (map-get? batches batch-id))
)

(define-read-only (get-batch-history (batch-id uint))
  (ok (map-get? batch-history batch-id))
)

;; SIP-010 implementation
(define-read-only (get-name)
  (ok "FuelChain Token")
)

(define-read-only (get-symbol)
  (ok "FUEL")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance fuel-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply fuel-token))
)
