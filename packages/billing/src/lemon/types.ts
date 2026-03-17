/**
 * Lemon Squeezy Webhook イベントの型定義
 * https://docs.lemonsqueezy.com/api/webhooks
 */

export type LemonSubscriptionStatus =
  | "on_trial"
  | "active"
  | "paused"
  | "past_due"
  | "unpaid"
  | "cancelled"
  | "expired";

export type LemonEventName =
  | "subscription_created"
  | "subscription_updated"
  | "subscription_cancelled"
  | "subscription_resumed"
  | "subscription_expired"
  | "subscription_paused"
  | "subscription_unpaused"
  | "subscription_payment_success"
  | "subscription_payment_failed"
  | "subscription_payment_recovered"
  | "order_created"
  | "order_refunded";

export interface LemonSubscriptionAttributes {
  store_id: number;
  customer_id: number;
  order_id: number;
  order_item_id: number;
  product_id: number;
  variant_id: number;
  product_name: string;
  variant_name: string;
  status: LemonSubscriptionStatus;
  status_formatted: string;
  pause: { mode: string; resumes_at: string | null } | null;
  cancelled: boolean;
  trial_ends_at: string | null;
  billing_anchor: number;
  urls: {
    update_payment_method: string;
    customer_portal: string;
  };
  renews_at: string | null;
  ends_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface LemonWebhookEvent {
  meta: {
    event_name: LemonEventName;
    /** Lemon Squeezy が各配信ごとに付与するユニーク ID（冪等性キーに使用） */
    custom_data?: {
      /** チェックアウト時に埋め込んだ Supabase user.id */
      user_id?: string;
    };
  };
  data: {
    id: string;
    type: string;
    attributes: LemonSubscriptionAttributes;
  };
}
