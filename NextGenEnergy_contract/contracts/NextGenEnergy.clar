
;; title: NextGenEnergy
;; version: 1.0.0
;; summary: Synthetic assets smart contract for fusion power and revolutionary energy technology development
;; description: Tracks energy technology investments, fusion power milestones, and synthetic asset performance

;; =============================================
;; CONSTANTS
;; =============================================

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-AMOUNT (err u402))
(define-constant ERR-ASSET-NOT-FOUND (err u404))
(define-constant ERR-MILESTONE-EXISTS (err u409))
(define-constant ERR-INSUFFICIENT-BALANCE (err u403))

;; Energy technology types
(define-constant FUSION-POWER u1)
(define-constant SOLAR-ADVANCED u2)
(define-constant WIND-NEXT-GEN u3)
(define-constant GEOTHERMAL-ENHANCED u4)
(define-constant HYDROGEN-FUEL u5)

;; =============================================
;; DATA VARIABLES
;; =============================================

(define-data-var next-asset-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var total-assets-value uint u0)
(define-data-var contract-active bool true)

;; =============================================
;; DATA MAPS
;; =============================================

;; Synthetic energy assets
(define-map energy-assets
  uint
  {
    name: (string-ascii 50),
    technology-type: uint,
    total-supply: uint,
    current-value: uint,
    performance-index: uint,
    created-at: uint,
    creator: principal
  }
)

;; User asset balances
(define-map user-balances
  { user: principal, asset-id: uint }
  { balance: uint }
)

;; Technology development milestones
(define-map development-milestones
  uint
  {
    asset-id: uint,
    milestone-name: (string-ascii 100),
    description: (string-ascii 200),
    target-date: uint,
    completion-status: bool,
    impact-multiplier: uint,
    achieved-at: (optional uint)
  }
)

;; Fusion power specific metrics
(define-map fusion-metrics
  uint
  {
    asset-id: uint,
    plasma-temperature: uint,
    energy-gain-factor: uint,
    uptime-percentage: uint,
    last-updated: uint
  }
)

;; Investment tracking
(define-map investments
  { investor: principal, asset-id: uint }
  {
    amount-invested: uint,
    shares-owned: uint,
    investment-date: uint
  }
)

;; Authorized managers
(define-map authorized-managers principal bool)

;; =============================================
;; AUTHORIZATION FUNCTIONS
;; =============================================

(define-private (is-authorized (user principal))
  (or
    (is-eq user CONTRACT-OWNER)
    (default-to false (map-get? authorized-managers user))
  )
)

;; =============================================
;; ASSET MANAGEMENT FUNCTIONS
;; =============================================

;; Create a new synthetic energy asset
(define-public (create-energy-asset
  (name (string-ascii 50))
  (technology-type uint)
  (initial-supply uint)
  (initial-value uint))
  (let
    (
      (asset-id (var-get next-asset-id))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> initial-supply u0) ERR-INVALID-AMOUNT)
    (asserts! (> initial-value u0) ERR-INVALID-AMOUNT)

    ;; Create the asset
    (map-set energy-assets asset-id
      {
        name: name,
        technology-type: technology-type,
        total-supply: initial-supply,
        current-value: initial-value,
        performance-index: u100, ;; Starting at 100%
        created-at: block-height,
        creator: tx-sender
      }
    )

    ;; Set creator's initial balance
    (map-set user-balances
      { user: tx-sender, asset-id: asset-id }
      { balance: initial-supply }
    )

    ;; Update contract state
    (var-set next-asset-id (+ asset-id u1))
    (var-set total-assets-value (+ (var-get total-assets-value) (* initial-supply initial-value)))

    (ok asset-id)
  )
)

;; Update asset performance and value
(define-public (update-asset-performance
  (asset-id uint)
  (new-performance-index uint)
  (new-value uint))
  (let
    (
      (asset-data (unwrap! (map-get? energy-assets asset-id) ERR-ASSET-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> new-value u0) ERR-INVALID-AMOUNT)

    (map-set energy-assets asset-id
      (merge asset-data
        {
          current-value: new-value,
          performance-index: new-performance-index
        }
      )
    )
    (ok true)
  )
)

;; Transfer asset shares between users
(define-public (transfer-asset-shares
  (asset-id uint)
  (amount uint)
  (recipient principal))
  (let
    (
      (sender-balance (default-to u0 (get balance (map-get? user-balances { user: tx-sender, asset-id: asset-id }))))
    )
    (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)

    ;; Update sender balance
    (map-set user-balances
      { user: tx-sender, asset-id: asset-id }
      { balance: (- sender-balance amount) }
    )

    ;; Update recipient balance
    (let
      (
        (recipient-balance (default-to u0 (get balance (map-get? user-balances { user: recipient, asset-id: asset-id }))))
      )
      (map-set user-balances
        { user: recipient, asset-id: asset-id }
        { balance: (+ recipient-balance amount) }
      )
    )
    (ok true)
  )
)

;; =============================================
;; MILESTONE MANAGEMENT FUNCTIONS
;; =============================================

;; Create development milestone
(define-public (create-milestone
  (asset-id uint)
  (milestone-name (string-ascii 100))
  (description (string-ascii 200))
  (target-date uint)
  (impact-multiplier uint))
  (let
    (
      (milestone-id (var-get next-milestone-id))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? energy-assets asset-id)) ERR-ASSET-NOT-FOUND)

    (map-set development-milestones milestone-id
      {
        asset-id: asset-id,
        milestone-name: milestone-name,
        description: description,
        target-date: target-date,
        completion-status: false,
        impact-multiplier: impact-multiplier,
        achieved-at: none
      }
    )

    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

;; Complete a milestone
(define-public (complete-milestone (milestone-id uint))
  (let
    (
      (milestone (unwrap! (map-get? development-milestones milestone-id) ERR-ASSET-NOT-FOUND))
      (asset-id (get asset-id milestone))
      (asset-data (unwrap! (map-get? energy-assets asset-id) ERR-ASSET-NOT-FOUND))
      (impact-multiplier (get impact-multiplier milestone))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get completion-status milestone)) ERR-MILESTONE-EXISTS)

    ;; Mark milestone as complete
    (map-set development-milestones milestone-id
      (merge milestone
        {
          completion-status: true,
          achieved-at: (some block-height)
        }
      )
    )

    ;; Update asset performance based on milestone impact
    (let
      (
        (current-performance (get performance-index asset-data))
        (new-performance (+ current-performance impact-multiplier))
      )
      (map-set energy-assets asset-id
        (merge asset-data { performance-index: new-performance })
      )
    )
    (ok true)
  )
)

;; =============================================
;; FUSION POWER SPECIFIC FUNCTIONS
;; =============================================

;; Update fusion power metrics
(define-public (update-fusion-metrics
  (asset-id uint)
  (plasma-temperature uint)
  (energy-gain-factor uint)
  (uptime-percentage uint))
  (begin
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? energy-assets asset-id)) ERR-ASSET-NOT-FOUND)

    (map-set fusion-metrics asset-id
      {
        asset-id: asset-id,
        plasma-temperature: plasma-temperature,
        energy-gain-factor: energy-gain-factor,
        uptime-percentage: uptime-percentage,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

;; =============================================
;; INVESTMENT FUNCTIONS
;; =============================================

;; Record investment in an energy asset
(define-public (invest-in-asset
  (asset-id uint)
  (amount uint))
  (let
    (
      (asset-data (unwrap! (map-get? energy-assets asset-id) ERR-ASSET-NOT-FOUND))
      (current-value (get current-value asset-data))
      (shares-purchased (/ amount current-value))
    )
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (> shares-purchased u0) ERR-INVALID-AMOUNT)

    ;; Record investment
    (map-set investments
      { investor: tx-sender, asset-id: asset-id }
      {
        amount-invested: amount,
        shares-owned: shares-purchased,
        investment-date: block-height
      }
    )

    ;; Update user balance
    (let
      (
        (current-balance (default-to u0 (get balance (map-get? user-balances { user: tx-sender, asset-id: asset-id }))))
      )
      (map-set user-balances
        { user: tx-sender, asset-id: asset-id }
        { balance: (+ current-balance shares-purchased) }
      )
    )
    (ok shares-purchased)
  )
)

;; =============================================
;; ADMIN FUNCTIONS
;; =============================================

;; Add authorized manager
(define-public (add-manager (manager principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set authorized-managers manager true)
    (ok true)
  )
)

;; Remove authorized manager
(define-public (remove-manager (manager principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-delete authorized-managers manager)
    (ok true)
  )
)

;; Emergency pause contract
(define-public (toggle-contract-status)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set contract-active (not (var-get contract-active)))
    (ok (var-get contract-active))
  )
)

;; =============================================
;; READ-ONLY FUNCTIONS
;; =============================================

;; Get asset information
(define-read-only (get-asset-info (asset-id uint))
  (map-get? energy-assets asset-id)
)

;; Get user balance for specific asset
(define-read-only (get-user-balance (user principal) (asset-id uint))
  (default-to u0 (get balance (map-get? user-balances { user: user, asset-id: asset-id })))
)

;; Get milestone information
(define-read-only (get-milestone-info (milestone-id uint))
  (map-get? development-milestones milestone-id)
)

;; Get fusion metrics
(define-read-only (get-fusion-metrics (asset-id uint))
  (map-get? fusion-metrics asset-id)
)

;; Get investment information
(define-read-only (get-investment-info (investor principal) (asset-id uint))
  (map-get? investments { investor: investor, asset-id: asset-id })
)

;; Get total contract value
(define-read-only (get-total-assets-value)
  (var-get total-assets-value)
)

;; Check if user is authorized
(define-read-only (is-manager (user principal))
  (is-authorized user)
)

;; Get contract status
(define-read-only (get-contract-status)
  (var-get contract-active)
)

;; Get next available asset ID
(define-read-only (get-next-asset-id)
  (var-get next-asset-id)
)

;; Get next available milestone ID
(define-read-only (get-next-milestone-id)
  (var-get next-milestone-id)
)
