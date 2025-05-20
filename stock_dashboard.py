
import pandas as pd
import panel as pn
import hvplot.pandas  

pn.extension("tabulator")

CSV_PATH = "pred_true_records.csv"  

df = pd.read_csv(CSV_PATH)

required_cols = {"stock_id", "week", "bucket", "true", "pred"}
missing = required_cols - set(df.columns)
if missing:
    raise ValueError(f"{', '.join(missing)}")



df["stock_id"] = df["stock_id"].astype(str)
df["week"] = df["week"].astype(int)
stock_select = pn.widgets.Select(name="Stock", options=sorted(df["stock_id"].unique()))
week_select = pn.widgets.Select(name="Week", options=sorted(df["week"].unique()))
@pn.depends(stock=stock_select, week=week_select)
def make_plot(stock: str, week):
    subset = df[(df["stock_id"] == stock) & (df["week"] == int(week))]

    if subset.empty:
        return pn.pane.Alert(f"⚠️ Stock {stock} 在 Week {week} 没有数据", alert_type="warning")

    
    y_cols = [col for col in ("true", "pred") if subset[col].notna().any()]
    if not y_cols:
        return pn.pane.Alert("⚠️ 该组合下无可绘制数值", alert_type="warning")

    return subset.hvplot(
        x="bucket",
        y=y_cols,
        xlabel="Bucket",
        ylabel="Value",
        width=900,
        height=400,
        title=f"Stock {stock} – Week {week}",
        legend="top_left",
        line_width=2,
    )


header = pn.pane.Markdown(
    """# 📈 Stock Forecast Dashboard  \n选择股票与周，查看模型预测与真实值对比""",
    sizing_mode="stretch_width",
)

dash = pn.Column(
    header,
    pn.Row(stock_select, week_select, sizing_mode="stretch_width"),
    make_plot,
    sizing_mode="stretch_width",
)
dash.servable()
