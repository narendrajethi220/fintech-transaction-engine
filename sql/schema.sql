
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
