;; Error codes
(define-constant ERR-NOT-MEMBER (err u100))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-VOTED (err u102))
(define-constant ERR-QUORUM-NOT-MET (err u103))
(define-constant ERR-PROPOSAL-CLOSED (err u104))
(define-constant ERR-PROPOSAL-STILL-OPEN (err u105))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-DATA (err u500))

;; Data variables
(define-data-var quorum-threshold uint u3)
(define-data-var proposal-count uint u0)

;; Maps
(define-map dao-members principal bool)
(define-map proposals
  {id: uint}
  {
    proposer: principal,
    description: (string-ascii 200),
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    open: bool
  }
)

(define-map votes
  {
    proposal-id: uint,
    voter: principal
  }
  bool
)

(define-public (add-member (new-member principal))
  (begin
    (asserts! (is-eq tx-sender 'SP000000000000000000002Q6VF78) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? dao-members new-member)) ERR-INVALID-DATA)
    (ok (map-insert dao-members new-member true))
  )
)

(define-public (create-proposal (desc (string-ascii 200)))
  (let 
    (
      (member (default-to false (map-get? dao-members tx-sender)))
      (new-id (+ (var-get proposal-count) u1))
      (proposal-data {
        proposer: tx-sender,
        description: desc,
        yes-votes: u0,
        no-votes: u0,
        executed: false,
        open: true
      })
    )
    (asserts! (is-eq member true) ERR-NOT-MEMBER)
    (var-set proposal-count new-id)
    (asserts! (is-none (map-get? proposals {id: new-id})) ERR-INVALID-DATA)
    (ok (map-insert proposals {id: new-id} proposal-data))
  )
)

(define-public (vote (proposal-id uint) (in-favor bool))
  (let
    (
      (member (default-to false (map-get? dao-members tx-sender)))
      (proposal (unwrap! (map-get? proposals {id: proposal-id}) ERR-PROPOSAL-NOT-FOUND))
      (vote-key {proposal-id: proposal-id, voter: tx-sender})
      (proposal-key {id: proposal-id})
    )
    (asserts! (is-eq member true) ERR-NOT-MEMBER)
    (asserts! (get open proposal) ERR-PROPOSAL-CLOSED)
    (asserts! (is-none (map-get? votes vote-key)) ERR-ALREADY-VOTED)
    (asserts! (map-insert votes vote-key true) ERR-INVALID-DATA)
    
    (ok 
      (if in-favor
          (map-set proposals proposal-key
            (merge proposal {yes-votes: (+ (get yes-votes proposal) u1)}))
          (map-set proposals proposal-key
            (merge proposal {no-votes: (+ (get no-votes proposal) u1)}))
      )
    )
  )
)

(define-public (close-proposal (proposal-id uint))
  (let 
    (
      (proposal (unwrap! (map-get? proposals {id: proposal-id}) ERR-PROPOSAL-NOT-FOUND))
      (proposal-key {id: proposal-id})
    )
    (asserts! (get open proposal) ERR-PROPOSAL-STILL-OPEN)
    (ok (map-set proposals proposal-key
      (merge proposal {open: false})))
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let 
    (
      (proposal (unwrap! (map-get? proposals {id: proposal-id}) ERR-PROPOSAL-NOT-FOUND))
      (proposal-key {id: proposal-id})
      (yes-votes (get yes-votes proposal))
      (no-votes (get no-votes proposal))
      (total-votes (+ yes-votes no-votes))
    )
    (asserts! (not (get open proposal)) ERR-PROPOSAL-STILL-OPEN)
    (asserts! (>= total-votes (var-get quorum-threshold)) ERR-QUORUM-NOT-MET)
    (if (>= yes-votes no-votes)
        (begin
          ;; Here is where you'd insert execution logic
          ;; e.g., call another contract, release funds, etc.
          (ok (map-set proposals proposal-key
            (merge proposal {executed: true})))
        )
        (err u106) ;; Proposal did not pass
    )
  )
)
