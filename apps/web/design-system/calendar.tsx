"use client";

import { useMemo, useState } from "react";
import { Button } from "./primitives";

const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export function Calendar({ initialDate = new Date(2026, 7, 8), onSelect }: { initialDate?: Date; onSelect?: (date: Date) => void }) {
  const [visibleMonth, setVisibleMonth] = useState(new Date(initialDate.getFullYear(), initialDate.getMonth(), 1));
  const [selected, setSelected] = useState(initialDate);
  const days = useMemo(() => {
    const firstOffset = (visibleMonth.getDay() + 6) % 7;
    const count = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 0).getDate();
    return [...Array(firstOffset).fill(null), ...Array.from({ length: count }, (_, index) => new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), index + 1))];
  }, [visibleMonth]);

  function choose(date: Date) {
    setSelected(date);
    onSelect?.(date);
  }

  return <div className="s-calendar" aria-label="Calendar">
    <div className="s-calendar__header"><Button size="compact" variant="quiet" aria-label="Previous month" onClick={() => setVisibleMonth(new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1))}>←</Button><strong>{visibleMonth.toLocaleDateString("en-GB", { month: "long", year: "numeric" })}</strong><Button size="compact" variant="quiet" aria-label="Next month" onClick={() => setVisibleMonth(new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1))}>→</Button></div>
    <div className="s-calendar__grid" role="grid"><div className="s-calendar__weekdays" role="row">{weekdays.map((day) => <span role="columnheader" key={day}>{day}</span>)}</div><div className="s-calendar__days">{days.map((date, index) => date ? <button type="button" role="gridcell" aria-selected={date.toDateString() === selected.toDateString()} className={date.toDateString() === selected.toDateString() ? "is-selected" : ""} key={date.toISOString()} onClick={() => choose(date)}>{date.getDate()}</button> : <span aria-hidden="true" key={`empty-${index}`} />)}</div></div>
    <p className="s-calendar__timezone">Times shown in Europe/London</p>
  </div>;
}
