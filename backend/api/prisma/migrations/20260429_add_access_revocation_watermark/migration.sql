-- Per-wallet access-token invalidation watermark for auth incident response.

CREATE TABLE "AuthAccessRevocation" (
    "address" VARCHAR(64) NOT NULL,
    "notBefore" TIMESTAMP(3) NOT NULL,
    "reason" VARCHAR(120),
    "actorAddress" VARCHAR(64),
    "requestId" VARCHAR(128),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuthAccessRevocation_pkey" PRIMARY KEY ("address")
);

CREATE INDEX "AuthAccessRevocation_notBefore_idx" ON "AuthAccessRevocation"("notBefore");
