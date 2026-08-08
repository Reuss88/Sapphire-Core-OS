import type { ButtonHTMLAttributes, ElementType, HTMLAttributes, InputHTMLAttributes, ReactNode, SelectHTMLAttributes, TextareaHTMLAttributes } from "react";
import { forwardRef } from "react";
import Link from "next/link";
import type { SapphireCardVariant } from "./tokens";

function cx(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "quiet" | "danger";
  size?: "compact" | "standard";
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button({ variant = "secondary", size = "standard", className, type = "button", ...props }, ref) {
  return <button ref={ref} type={type} className={cx("s-button", `s-button--${variant}`, `s-button--${size}`, className)} {...props} />;
});

export function LinkButton({ href, children, variant = "secondary", size = "standard", className, ...props }: { href: string; children: ReactNode; variant?: ButtonProps["variant"]; size?: ButtonProps["size"]; className?: string } & Omit<HTMLAttributes<HTMLAnchorElement>, "href">) {
  return <Link href={href} className={cx("s-button", `s-button--${variant}`, `s-button--${size}`, className)} {...props}>{children}</Link>;
}

export interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  label: string;
}

export function IconButton({ label, className, type = "button", ...props }: IconButtonProps) {
  return <button type={type} aria-label={label} className={cx("s-icon-button", className)} {...props} />;
}

export interface CardProps extends HTMLAttributes<HTMLElement> {
  as?: ElementType;
  variant?: SapphireCardVariant;
  chrome?: "forward" | "reverse" | "none";
  headerGradient?: boolean;
  children: ReactNode;
}

export function Card({ as: Component = "section", variant = "standard", chrome = "forward", headerGradient = false, className, children, ...props }: CardProps) {
  return <Component className={cx("s-card", `s-card--${variant}`, chrome !== "none" && `s-card--chrome-${chrome}`, headerGradient && "s-card--header-gradient", className)} {...props}>{children}</Component>;
}

export function CardHeader({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cx("s-card__header", className)} {...props} />;
}

export function CardBody({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cx("s-card__body", className)} {...props} />;
}

export function Eyebrow({ className, ...props }: HTMLAttributes<HTMLParagraphElement>) {
  return <p className={cx("s-eyebrow", className)} {...props} />;
}

export function StatusBadge({ tone = "neutral", className, ...props }: HTMLAttributes<HTMLSpanElement> & { tone?: "neutral" | "info" | "success" | "warning" | "critical" | "ai" }) {
  return <span className={cx("s-status-badge", `s-status-badge--${tone}`, className)} {...props} />;
}

export interface FieldProps {
  label: string;
  hint?: string;
  error?: string;
  authorityNote?: string;
  required?: boolean;
  optional?: boolean;
  children: ReactNode;
}

export function Field({ label, hint, error, authorityNote, required, optional, children }: FieldProps) {
  return <label className="s-field"><span className="s-field__label">{label}{required && <b aria-hidden="true"> *</b>}{optional && <small>Optional</small>}</span>{children}{error ? <span className="s-field__error">{error}</span> : hint ? <span className="s-field__hint">{hint}</span> : null}{authorityNote && <span className="s-field__authority">◇ {authorityNote}</span>}</label>;
}

export const Input = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(function Input({ className, ...props }, ref) {
  return <input ref={ref} className={cx("s-input", className)} {...props} />;
});

export function Select({ className, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return <select className={cx("s-select", className)} {...props} />;
}

export function Textarea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className={cx("s-textarea", className)} {...props} />;
}

export function ButtonGroup({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return <div className={cx("s-button-group", className)} role="group" {...props} />;
}

export function Avatar({ initials, label, className }: { initials: string; label: string; className?: string }) {
  return <span className={cx("s-avatar", className)} role="img" aria-label={label}>{initials}</span>;
}

export function ProvenanceMarker({ children, className }: { children: ReactNode; className?: string }) {
  return <span className={cx("s-provenance", className)}>✦ {children}</span>;
}

export function SharedState({ state, title, detail, action }: { state: "loading" | "empty" | "stale" | "partial" | "offline" | "error" | "unauthorised"; title: string; detail: string; action?: ReactNode }) {
  return <div className={`s-shared-state s-shared-state--${state}`} role={state === "error" ? "alert" : "status"}><span aria-hidden="true">{state === "loading" ? "◌" : state === "error" ? "!" : "◇"}</span><strong>{title}</strong><p>{detail}</p>{action}</div>;
}
