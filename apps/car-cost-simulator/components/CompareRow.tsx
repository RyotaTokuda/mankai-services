import { formatYen } from "../lib/calc";

export default function CompareRow({
  label,
  values,
  highlight,
}: {
  label: string;
  values: number[];
  highlight?: boolean;
}) {
  const min = Math.min(...values);
  const max = Math.max(...values);
  const diff = max - min;

  return (
    <tr
      className={`border-b border-slate-100 dark:border-slate-700 ${
        highlight ? "font-bold bg-amber-50/50 dark:bg-amber-950/20" : ""
      }`}
    >
      <td className="py-2.5 pr-4 text-slate-500">{label}</td>
      {values.map((v, i) => (
        <td
          key={i}
          className={`text-right py-2.5 px-3 tabular-nums ${
            values.length > 1 && v === min
              ? "text-green-600 dark:text-green-400"
              : ""
          }`}
        >
          {formatYen(v)} 円
        </td>
      ))}
      <td className="text-right py-2.5 pl-3 text-slate-400 tabular-nums">
        {values.length > 1 ? `${formatYen(diff)} 円` : "-"}
      </td>
    </tr>
  );
}
