;; pbcoin.clar
;; A simple fungible token smart contract for the pbcoin project.

(define-constant token-name "pbcoin")
(define-constant token-symbol "PB")
(define-constant token-decimals u6)

;; Sentinel owner value used before the contract is initialized.
(define-constant contract-owner-sentinel 'SP000000000000000000002Q6VF78)

;; Error codes
(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-ALREADY-INITIALIZED u101)
(define-constant ERR-NOT-INITIALIZED u102)
(define-constant ERR-INSUFFICIENT-BALANCE u103)
(define-constant ERR-ZERO-AMOUNT u104)

;; Contract owner and total supply
(define-data-var contract-owner principal contract-owner-sentinel)
(define-data-var total-supply uint u0)

;; Balances map
(define-map balances
  { owner: principal }
  { balance: uint })

;; Read-only helpers
(define-read-only (get-name)
  token-name)

(define-read-only (get-symbol)
  token-symbol)

(define-read-only (get-decimals)
  token-decimals)

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-read-only (get-owner)
  (var-get contract-owner))

(define-read-only (get-balance (owner principal))
  (get balance (default-to { balance: u0 }
    (map-get? balances { owner: owner }))))

;; Internal helpers
(define-private (is-owner (sender principal))
  (is-eq sender (var-get contract-owner)))

(define-private (is-initialized)
  (not (is-eq (var-get contract-owner) contract-owner-sentinel)))

(define-private (transfer-internal (sender principal) (recipient principal) (amount uint))
  (if (is-eq amount u0)
      (err ERR-ZERO-AMOUNT)
      (let (
        (sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient))
      )
        (if (< sender-balance amount)
            (err ERR-INSUFFICIENT-BALANCE)
            (begin
              (map-set balances { owner: sender } { balance: (- sender-balance amount) })
              (map-set balances { owner: recipient } { balance: (+ recipient-balance amount) })
              (ok true))))))

;; Public functions

;; One-time initialization: sets the contract owner to the tx-sender.
(define-public (initialize)
  (if (is-eq (var-get contract-owner) contract-owner-sentinel)
      (begin
        (var-set contract-owner tx-sender)
        (ok true))
      (err ERR-ALREADY-INITIALIZED)))

;; Transfer tokens from tx-sender to the given recipient.
(define-public (transfer (amount uint) (recipient principal))
  (if (not (is-initialized))
      (err ERR-NOT-INITIALIZED)
      (transfer-internal tx-sender recipient amount)))

;; Mint new tokens to a recipient. Only the contract owner can mint.
(define-public (mint (amount uint) (recipient principal))
  (if (not (is-initialized))
      (err ERR-NOT-INITIALIZED)
      (if (not (is-owner tx-sender))
          (err ERR-NOT-OWNER)
          (if (is-eq amount u0)
              (err ERR-ZERO-AMOUNT)
              (let (
                (current-total (var-get total-supply))
                (recipient-balance (get-balance recipient))
              )
                (var-set total-supply (+ current-total amount))
                (map-set balances { owner: recipient } { balance: (+ recipient-balance amount) })
                (ok true))))))

;; Burn tokens from the caller's balance.
(define-public (burn (amount uint))
  (if (not (is-initialized))
      (err ERR-NOT-INITIALIZED)
      (if (is-eq amount u0)
          (err ERR-ZERO-AMOUNT)
          (let (
            (sender-balance (get-balance tx-sender))
            (current-total (var-get total-supply))
          )
            (if (< sender-balance amount)
                (err ERR-INSUFFICIENT-BALANCE)
                (begin
                  (map-set balances { owner: tx-sender } { balance: (- sender-balance amount) })
                  (var-set total-supply (- current-total amount))
                  (ok true)))))))
