-- Durable append-only evidence for privileged wallet and operational access decisions.

CREATE TABLE "PrivilegedAuditEvent" (
    "id" TEXT NOT NULL,
    "requestId" VARCHAR(128) NOT NULL,
    "method" VARCHAR(16) NOT NULL,
    "path" VARCHAR(512) NOT NULL,
    "principalType" VARCHAR(32) NOT NULL,
    "actorAddress" VARCHAR(64),
    "requiredRoles" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    "tokenRoles" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    "currentRoles" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    "decision" VARCHAR(16) NOT NULL,
    "reason" VARCHAR(120),
    "outcome" VARCHAR(16) NOT NULL,
    "statusCode" INTEGER NOT NULL,
    "responseTimeMs" DOUBLE PRECISION NOT NULL,
    "ipHash" VARCHAR(64) NOT NULL,
    "userAgentHash" VARCHAR(64) NOT NULL,
    "eventHash" VARCHAR(64) NOT NULL,
    "previousEventHash" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PrivilegedAuditEvent_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PrivilegedAuditEvent_eventHash_key" ON "PrivilegedAuditEvent"("eventHash");
CREATE INDEX "PrivilegedAuditEvent_requestId_idx" ON "PrivilegedAuditEvent"("requestId");
CREATE INDEX "PrivilegedAuditEvent_actorAddress_idx" ON "PrivilegedAuditEvent"("actorAddress");
CREATE INDEX "PrivilegedAuditEvent_decision_idx" ON "PrivilegedAuditEvent"("decision");
CREATE INDEX "PrivilegedAuditEvent_outcome_idx" ON "PrivilegedAuditEvent"("outcome");
CREATE INDEX "PrivilegedAuditEvent_createdAt_idx" ON "PrivilegedAuditEvent"("createdAt");

CREATE OR REPLACE FUNCTION prevent_privileged_audit_event_mutation()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'PrivilegedAuditEvent is append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "PrivilegedAuditEvent_prevent_mutation"
BEFORE UPDATE OR DELETE ON "PrivilegedAuditEvent"
FOR EACH ROW EXECUTE FUNCTION prevent_privileged_audit_event_mutation();
