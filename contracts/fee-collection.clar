;; Fee Collection Contract
;; Handles vendor payments and fee management

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-VENDOR-NOT-FOUND (err u201))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u202))
(define-constant ERR-INVALID-FEE-TYPE (err u203))
(define-constant ERR-PAYMENT-NOT-FOUND (err u204))
(define-constant ERR-INVALID-INPUT (err u205))

;; Fee Types
(define-constant FEE-TYPE-DAILY "daily")
(define-constant FEE-TYPE-WEEKLY "weekly")
(define-constant FEE-TYPE-MONTHLY "monthly")

;; Data Variables
(define-data-var next-payment-id uint u1)
(define-data-var late-fee-percentage uint u10) ;; 10% late fee

;; Data Maps
(define-map vendor-balances
  { vendor: principal }
  {
    outstanding-balance: uint,
    total-paid: uint,
    last-payment-date: uint,
    payment-plan: (string-ascii 20)
  }
)

(define-map payments
  { payment-id: uint }
  {
    vendor: principal,
    amount: uint,
    fee-type: (string-ascii 20),
    payment-date: uint,
    due-date: uint,
    late-fee: uint,
    status: (string-ascii 20)
  }
)

(define-map fee-structures
  { fee-type: (string-ascii 20) }
  {
    base-amount: uint,
    grace-period: uint,
    late-fee-rate: uint
  }
)

;; Initialize fee structures
(map-set fee-structures { fee-type: FEE-TYPE-DAILY } { base-amount: u50, grace-period: u1, late-fee-rate: u5 })
(map-set fee-structures { fee-type: FEE-TYPE-WEEKLY } { base-amount: u300, grace-period: u7, late-fee-rate: u10 })
(map-set fee-structures { fee-type: FEE-TYPE-MONTHLY } { base-amount: u1200, grace-period: u30, late-fee-rate: u15 })

;; Public Functions

;; Register vendor for fee collection
(define-public (register-vendor (vendor principal) (payment-plan (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (or (is-eq payment-plan FEE-TYPE-DAILY)
                  (is-eq payment-plan FEE-TYPE-WEEKLY)
                  (is-eq payment-plan FEE-TYPE-MONTHLY)) ERR-INVALID-FEE-TYPE)

    (map-set vendor-balances
      { vendor: vendor }
      {
        outstanding-balance: u0,
        total-paid: u0,
        last-payment-date: u0,
        payment-plan: payment-plan
      }
    )

    (ok true)
  )
)

;; Process vendor payment
(define-public (make-payment (amount uint) (fee-type (string-ascii 20)))
  (let (
    (vendor-balance (unwrap! (map-get? vendor-balances { vendor: tx-sender }) ERR-VENDOR-NOT-FOUND))
    (fee-structure (unwrap! (map-get? fee-structures { fee-type: fee-type }) ERR-INVALID-FEE-TYPE))
    (payment-id (var-get next-payment-id))
    (due-date (+ block-height (get grace-period fee-structure)))
  )
    (asserts! (>= amount (get base-amount fee-structure)) ERR-INSUFFICIENT-PAYMENT)

    ;; Record payment
    (map-set payments
      { payment-id: payment-id }
      {
        vendor: tx-sender,
        amount: amount,
        fee-type: fee-type,
        payment-date: block-height,
        due-date: due-date,
        late-fee: u0,
        status: "paid"
      }
    )

    ;; Update vendor balance
    (map-set vendor-balances
      { vendor: tx-sender }
      (merge vendor-balance {
        total-paid: (+ (get total-paid vendor-balance) amount),
        last-payment-date: block-height
      })
    )

    (var-set next-payment-id (+ payment-id u1))
    (ok payment-id)
  )
)

;; Add outstanding balance
(define-public (add-outstanding-balance (vendor principal) (amount uint) (fee-type (string-ascii 20)))
  (let ((vendor-balance (unwrap! (map-get? vendor-balances { vendor: vendor }) ERR-VENDOR-NOT-FOUND)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-INPUT)

    (map-set vendor-balances
      { vendor: vendor }
      (merge vendor-balance {
        outstanding-balance: (+ (get outstanding-balance vendor-balance) amount)
      })
    )

    (ok true)
  )
)

;; Apply late fee
(define-public (apply-late-fee (payment-id uint))
  (let (
    (payment (unwrap! (map-get? payments { payment-id: payment-id }) ERR-PAYMENT-NOT-FOUND))
    (fee-structure (unwrap! (map-get? fee-structures { fee-type: (get fee-type payment) }) ERR-INVALID-FEE-TYPE))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> block-height (get due-date payment)) ERR-INVALID-INPUT)

    (let (
      (late-fee (/ (* (get amount payment) (get late-fee-rate fee-structure)) u100))
      (vendor (get vendor payment))
      (vendor-balance (unwrap! (map-get? vendor-balances { vendor: vendor }) ERR-VENDOR-NOT-FOUND))
    )
      ;; Update payment with late fee
      (map-set payments
        { payment-id: payment-id }
        (merge payment {
          late-fee: late-fee,
          status: "late"
        })
      )

      ;; Add late fee to outstanding balance
      (map-set vendor-balances
        { vendor: vendor }
        (merge vendor-balance {
          outstanding-balance: (+ (get outstanding-balance vendor-balance) late-fee)
        })
      )

      (ok late-fee)
    )
  )
)

;; Update fee structure
(define-public (update-fee-structure (fee-type (string-ascii 20)) (base-amount uint) (grace-period uint) (late-fee-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> base-amount u0) ERR-INVALID-INPUT)
    (asserts! (<= late-fee-rate u50) ERR-INVALID-INPUT) ;; Max 50% late fee

    (map-set fee-structures
      { fee-type: fee-type }
      {
        base-amount: base-amount,
        grace-period: grace-period,
        late-fee-rate: late-fee-rate
      }
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get vendor balance
(define-read-only (get-vendor-balance (vendor principal))
  (map-get? vendor-balances { vendor: vendor })
)

;; Get payment details
(define-read-only (get-payment (payment-id uint))
  (map-get? payments { payment-id: payment-id })
)

;; Get fee structure
(define-read-only (get-fee-structure (fee-type (string-ascii 20)))
  (map-get? fee-structures { fee-type: fee-type })
)

;; Check if payment is overdue
(define-read-only (is-payment-overdue (payment-id uint))
  (match (map-get? payments { payment-id: payment-id })
    payment (> block-height (get due-date payment))
    false
  )
)

;; Get total outstanding balance for vendor
(define-read-only (get-outstanding-balance (vendor principal))
  (match (map-get? vendor-balances { vendor: vendor })
    balance (get outstanding-balance balance)
    u0
  )
)
