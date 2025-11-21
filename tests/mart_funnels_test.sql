models:
  - name: mart_funnels
    description: "Aggregated funnel metrics by campaign and channel"
    columns:
      - name: campaign_id
        tests:
          - not_null
          - unique
      - name: channel
        tests:
          - not_null
    tests:
      - test_mart_funnels_consistency  # your custom test macro
