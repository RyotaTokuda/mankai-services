import React, { createContext, useContext, useState, useCallback, type ReactNode } from "react";
import { type PlanType } from "./subscription";

type PlanStatus = "active" | "expired" | "none";

interface PlanState {
  planType: PlanType;
  readCount: number;
  monthlyReadCount: number;
  expiresAt: string | null;
  planExpiresAt: string | null;
  planStatus: PlanStatus;
}

interface PlanLimits {
  monthlyReads: number;
  monthlyReadLimit: number;
  historyDays: number;
  canAccessHistory: boolean;
  isAdFree: boolean;
  saveLimit: number;
  compareLimit: number;
  canUseAdvancedSimulation: boolean;
}

interface SubscriptionContextValue {
  state: PlanState;
  limits: PlanLimits;
  remainingReads: number;
  isLimitReached: boolean;
  incrementReadCount: () => void;
  restorePurchase: () => Promise<boolean>;
  debugSetPlan: (planType: PlanType, expired?: boolean) => void;
  debugResetCount: () => void;
}

const defaultState: PlanState = {
  planType: "free",
  readCount: 0,
  monthlyReadCount: 0,
  expiresAt: null,
  planExpiresAt: null,
  planStatus: "none",
};

const freeLimits: PlanLimits = {
  monthlyReads: 5,
  monthlyReadLimit: 5,
  historyDays: 7,
  canAccessHistory: false,
  isAdFree: false,
  saveLimit: 1,
  compareLimit: 0,
  canUseAdvancedSimulation: false,
};

const paidLimits: PlanLimits = {
  monthlyReads: -1,
  monthlyReadLimit: -1,
  historyDays: 365,
  canAccessHistory: true,
  isAdFree: true,
  saveLimit: -1,
  compareLimit: -1,
  canUseAdvancedSimulation: true,
};

const SubscriptionContext = createContext<SubscriptionContextValue>({
  state: defaultState,
  limits: freeLimits,
  remainingReads: 5,
  isLimitReached: false,
  incrementReadCount: () => {},
  restorePurchase: async () => false,
  debugSetPlan: () => {},
  debugResetCount: () => {},
});

export function SubscriptionProvider({ userId: _userId, children }: { userId?: string; children: ReactNode }) {
  const [state, setState] = useState<PlanState>(defaultState);

  const limits = state.planType === "free" ? freeLimits : paidLimits;

  const incrementReadCount = useCallback(() => {
    setState((prev) => ({
      ...prev,
      readCount: prev.readCount + 1,
      monthlyReadCount: prev.monthlyReadCount + 1,
    }));
  }, []);

  const remainingReads = limits.monthlyReads === -1
    ? Infinity
    : Math.max(0, limits.monthlyReads - state.readCount);
  const isLimitReached = state.planType === "free" && remainingReads <= 0;

  const restorePurchase = useCallback(async () => {
    // TODO: implement purchase restoration
    return false;
  }, []);

  const debugSetPlan = useCallback((planType: PlanType, expired?: boolean) => {
    setState((prev) => ({
      ...prev,
      planType,
      planStatus: expired ? "expired" : planType === "free" ? "none" : "active",
      expiresAt: expired ? new Date(Date.now() - 86400000).toISOString() : null,
      planExpiresAt: expired ? new Date(Date.now() - 86400000).toISOString() : null,
    }));
  }, []);

  const debugResetCount = useCallback(() => {
    setState((prev) => ({ ...prev, readCount: 0, monthlyReadCount: 0 }));
  }, []);

  return (
    <SubscriptionContext.Provider
      value={{ state, limits, remainingReads, isLimitReached, incrementReadCount, restorePurchase, debugSetPlan, debugResetCount }}
    >
      {children}
    </SubscriptionContext.Provider>
  );
}

export function usePlan() {
  return useContext(SubscriptionContext);
}
