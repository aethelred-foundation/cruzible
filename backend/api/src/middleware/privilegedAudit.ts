import type { Request, Response } from 'express';
import { logger } from '../utils/logger';

type PrivilegedPrincipalType = 'wallet' | 'operational-token';
type PrivilegedDecision = 'allowed' | 'rejected';

export interface PrivilegedAuditContext {
  principalType: PrivilegedPrincipalType;
  decision: PrivilegedDecision;
  reason?: string;
  actorAddress?: string;
  tokenRoles?: readonly string[];
  currentRoles?: readonly string[];
  requiredRoles?: readonly string[];
}

function getClientIp(req: Request): string {
  return req.ip || req.socket.remoteAddress || 'unknown';
}

function getAuditPath(req: Request): string {
  const rawPath = req.originalUrl || req.url || req.path || 'unknown';
  return rawPath.split('?')[0] || 'unknown';
}

function getOutcome(statusCode: number, decision: PrivilegedDecision): string {
  if (decision === 'rejected') {
    return 'rejected';
  }
  if (statusCode >= 500) {
    return 'failed';
  }
  if (statusCode >= 400) {
    return 'denied';
  }
  return 'succeeded';
}

export function auditPrivilegedAccess(
  req: Request,
  res: Response,
  context: PrivilegedAuditContext,
): void {
  const startTime = process.hrtime.bigint();
  let emitted = false;

  const emitAudit = () => {
    if (emitted) {
      return;
    }
    emitted = true;

    const elapsedNs = process.hrtime.bigint() - startTime;
    const elapsedMs = Number(elapsedNs) / 1_000_000;
    const statusCode = res.statusCode || 0;
    const auditEntry = {
      type: 'privileged_access_audit',
      timestamp: new Date().toISOString(),
      requestId: req.requestId || 'unknown',
      method: req.method,
      path: getAuditPath(req),
      principalType: context.principalType,
      actorAddress: context.actorAddress,
      requiredRoles: context.requiredRoles,
      tokenRoles: context.tokenRoles,
      currentRoles: context.currentRoles,
      decision: context.decision,
      reason: context.reason,
      outcome: getOutcome(statusCode, context.decision),
      statusCode,
      responseTimeMs: Math.round(elapsedMs * 100) / 100,
      ip: getClientIp(req),
      userAgent: req.get('user-agent') || 'unknown',
    };

    if (context.decision === 'rejected' || statusCode >= 400) {
      logger.warn('Privileged access audit', auditEntry);
      return;
    }

    logger.info('Privileged access audit', auditEntry);
  };

  res.once('finish', emitAudit);
  res.once('close', emitAudit);
}
