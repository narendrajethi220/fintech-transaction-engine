CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS loan_types (
    loan_type_id SMALLINT PRIMARY KEY
        GENERATED ALWAYS AS IDENTITY,
    type_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS loans (
    loan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    loan_type_id SMALLINT NOT NULL,
    principal_amount NUMERIC(15,2) NOT NULL,
    loan_status VARCHAR(20) NOT NULL,
    disbursement_date DATE NOT NULL,
    maturity_date DATE,

    CONSTRAINT chk_principal_amount
        CHECK (principal_amount > 0),

    CONSTRAINT chk_loan_status
        CHECK (loan_status IN ('ACTIVE', 'CLOSED', 'DEFAULTED')),

    CONSTRAINT chk_maturity_date
        CHECK (
            maturity_date IS NULL
            OR maturity_date >= disbursement_date
        ),

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_loan_type
        FOREIGN KEY (loan_type_id)
        REFERENCES loan_types(loan_type_id)
);

CREATE TABLE IF NOT EXISTS customer_addresses(
    address_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    pincode VARCHAR(15) NOT NULL,
    address_type VARCHAR(20) NOT NULL,

    CONSTRAINT fk_customer
        FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)

);

CREATE TABLE IF NOT EXISTS payment_transactions (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_transaction_id VARCHAR(100) UNIQUE NOT NULL,
    loan_id UUID NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    payment_mode VARCHAR(20) NOT NULL,
    current_status VARCHAR(20) NOT NULL,
    transaction_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id),

    CONSTRAINT chk_amount
        CHECK(amount > 0),

    CONSTRAINT chk_payment_mode
        CHECK(payment_mode IN ('UPI','NEFT','IMPS')),

    CONSTRAINT chk_payment_status
        CHECK(current_status IN ('PENDING','SUCCESS','FAILED'))
);

CREATE TABLE IF NOT EXISTS processing_batches (
    batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_file VARCHAR(255) NOT NULL,
    file_checksum VARCHAR(128),
    batch_status VARCHAR(20),
    total_records INTEGER,
    processed_records INTEGER,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    CONSTRAINT chk_processing_batches_total_records
        CHECK (total_records IS NULL OR total_records >= 0),

    CONSTRAINT chk_processing_batches_processed_records
        CHECK (
            processed_records IS NULL
            OR (
                processed_records >= 0
                AND (total_records IS NULL OR processed_records <= total_records)
            )
        ),

    CONSTRAINT chk_processing_batches_completed_at
        CHECK (completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at)
);

CREATE TABLE IF NOT EXISTS transaction_history (
    event_id VARCHAR(100) PRIMARY KEY,
    payment_id UUID,
    batch_id UUID NOT NULL,
    provider_transaction_id VARCHAR(100) NOT NULL,
    event_status VARCHAR(20),
    event_timestamp TIMESTAMPTZ,
    received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    raw_payload JSONB NOT NULL,
    processing_status VARCHAR(20),

    CONSTRAINT fk_transaction_history_payment
        FOREIGN KEY (payment_id)
        REFERENCES payment_transactions(payment_id),

    CONSTRAINT fk_transaction_history_batch
        FOREIGN KEY (batch_id)
        REFERENCES processing_batches(batch_id)

);

CREATE TABLE IF NOT EXISTS repayment_ledger (
    ledger_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL UNIQUE,
    loan_id UUID NOT NULL,
    amount_applied NUMERIC(15,2) NOT NULL,
    entry_type VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_repayment_ledger_amount_applied
        CHECK (amount_applied > 0),

    CONSTRAINT fk_repayment_ledger_payment
        FOREIGN KEY (payment_id)
        REFERENCES payment_transactions(payment_id),

    CONSTRAINT fk_repayment_ledger_loan
        FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);


CREATE TABLE IF NOT EXISTS dead_letter_records (
    dead_letter_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL,
    event_id VARCHAR(100),
    raw_payload JSONB NOT NULL,
    error_code VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_dead_letter_records_batch
        FOREIGN KEY (batch_id)
        REFERENCES processing_batches(batch_id)
);

CREATE TABLE IF NOT EXISTS reconciliation_results (
    reconciliation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL,
    provider_transaction_id VARCHAR(100),
    reconciliation_status VARCHAR(30),
    expected_amount NUMERIC(15,2),
    actual_amount NUMERIC(15,2),
    discrepancy TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reconciliation_results_batch
        FOREIGN KEY (batch_id)
        REFERENCES processing_batches(batch_id)
);
