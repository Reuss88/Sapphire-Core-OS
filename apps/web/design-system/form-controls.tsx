"use client";

import type { InputHTMLAttributes, ReactNode } from "react";

function cx(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(" ");
}

interface ChoiceProps extends Omit<InputHTMLAttributes<HTMLInputElement>, "type"> {
  label: ReactNode;
  description?: ReactNode;
}

function Choice({ type, label, description, className, ...props }: ChoiceProps & { type: "checkbox" | "radio" }) {
  return <label className={cx("s-choice", `s-choice--${type}`, className)}><input type={type} {...props} /><span className="s-choice__control" aria-hidden="true" /><span><strong>{label}</strong>{description && <small>{description}</small>}</span></label>;
}

export function Checkbox(props: ChoiceProps) {
  return <Choice type="checkbox" {...props} />;
}

export function Radio(props: ChoiceProps) {
  return <Choice type="radio" {...props} />;
}

export interface SwitchProps extends Omit<InputHTMLAttributes<HTMLInputElement>, "type" | "role"> {
  label: ReactNode;
  description?: ReactNode;
}

export function Switch({ label, description, className, ...props }: SwitchProps) {
  return <label className={cx("s-switch", className)}><input type="checkbox" role="switch" {...props} /><span className="s-switch__track" aria-hidden="true"><span /></span><span><strong>{label}</strong>{description && <small>{description}</small>}</span></label>;
}

export interface SegmentedOption {
  value: string;
  label: string;
  disabled?: boolean;
}

export function SegmentedControl({ label, value, options, onChange }: { label: string; value: string; options: SegmentedOption[]; onChange: (value: string) => void }) {
  return <fieldset className="s-segmented-control"><legend className="s-visually-hidden">{label}</legend>{options.map((option) => <button key={option.value} type="button" aria-pressed={value === option.value} disabled={option.disabled} onClick={() => onChange(option.value)}>{option.label}</button>)}</fieldset>;
}

export function DateField({ className, ...props }: Omit<InputHTMLAttributes<HTMLInputElement>, "type">) {
  return <input className={cx("s-input", className)} type="date" {...props} />;
}

export function TimeField({ className, ...props }: Omit<InputHTMLAttributes<HTMLInputElement>, "type">) {
  return <input className={cx("s-input", className)} type="time" {...props} />;
}

export function DateTimeField({ className, ...props }: Omit<InputHTMLAttributes<HTMLInputElement>, "type">) {
  return <input className={cx("s-input", className)} type="datetime-local" {...props} />;
}
