import pandas as pd
import panel as pn
import hvplot.pandas
from holoviews import opts

pn.extension("tabulator")

model_files = {
    "LSTM Model": "LSTM/LSTM_pred_true_records.csv",
    "AREWMA Model": "AREWMA_Model/predictions.csv",
    "LSTM+GARCH Hybrid Model": "Hybrid_Model/hybrid_predictions.csv",
    "EGARCH Model": "EGARCH/test_garch_predicted.csv",
}

metrics_files = {
    "LSTM Model": "/Users/shiyuchen/Downloads/DATA3888_Optiver_9_GroupCode/LSTM/LSTM_new_weekly_metrics.csv",
    "AREWMA Model": "/Users/shiyuchen/Downloads/DATA3888_Optiver_9_GroupCode/AREWMA_Model/metrics.csv",
    "LSTM+GARCH Hybrid Model": "/Users/shiyuchen/Downloads/DATA3888_Optiver_9_GroupCode/Hybrid_Model/hybrid_metrics.csv",
    "EGARCH Model": "/Users/shiyuchen/Downloads/DATA3888_Optiver_9_GroupCode/EGARCH/egarch_metrics.csv",
}


def standardize_df(df: pd.DataFrame, model: str) -> pd.DataFrame:
    """Return a DataFrame with unified columns: stock_id, week, bucket, true, pred, cluster."""

    df_copy = df.copy()

    if model == "AREWMA Model":
        df_copy = df_copy.rename(
            columns={
                "actual_volatility": "true",
                "ar_ewma_prediction": "pred",
                "time_seconds": "_time_tmp",
            }
        )
        if not all(col in df_copy.columns for col in ["stock_id", "week", "_time_tmp"]):
            raise ValueError(f"{model} is missing stock_id, week, or _time_tmp.")
        df_copy = df_copy.sort_values(["stock_id", "week", "_time_tmp"])
        df_copy["bucket"] = df_copy.groupby(["stock_id", "week"]).cumcount()
        df_copy = df_copy.drop(columns=["_time_tmp"])

    elif model == "EGARCH Model":
        df_copy = df_copy.rename(
            columns={"realized_volatility": "true", "predicted_volatility": "pred"}
        )

        if "date" not in df_copy.columns and (
            "week" not in df_copy.columns or "bucket_start" not in df_copy.columns
        ):
            raise ValueError("EGARCH data is missing required time columns.")

        if "date" in df_copy.columns:
            if not all(col in df_copy.columns for col in ["stock_id", "date", "bucket_start"]):
                raise ValueError(f"{model} is missing stock_id, date, or bucket_start.")
            df_copy = df_copy.sort_values(["stock_id", "date", "bucket_start"])
            df_copy["bucket"] = df_copy.groupby(["stock_id", "date"]).cumcount()
            if "week" not in df_copy.columns:
                try:
                    df_copy["week"] = (
                        pd.to_datetime(df_copy["date"]).dt.isocalendar().week.astype(int)
                    )
                except Exception:
                    print("1")
                    df_copy["week"] = 0
        else:
            if not all(col in df_copy.columns for col in ["stock_id", "week", "bucket_start"]):
                raise ValueError(f"{model} is missing stock_id, week, or bucket_start.")
            df_copy = df_copy.sort_values(["stock_id", "week", "bucket_start"])
            df_copy["bucket"] = df_copy.groupby(["stock_id", "week"]).cumcount()

        df_copy["cluster"] = df_copy.get("cluster", None)

    elif model == "LSTM+GARCH Hybrid Model":
        df_copy = df_copy.rename(
            columns={
                "actual": "true",
                "pred_hybrid": "pred",
                "time": "_time_tmp",
                "stock": "stock_id",
            }
        )
        if not all(col in df_copy.columns for col in ["stock_id", "week", "_time_tmp"]):
            raise ValueError(f"{model} is missing stock_id, week, or _time_tmp.")
        df_copy = df_copy.sort_values(["stock_id", "week", "_time_tmp"])
        df_copy["bucket"] = df_copy.groupby(["stock_id", "week"]).cumcount()
        df_copy = df_copy.drop(columns=["_time_tmp"])

    elif model == "LSTM Model":
        df_copy = df_copy.rename(columns={"true_value": "true", "predicted_value": "pred"})
        if "time" in df_copy.columns and "week" in df_copy.columns and "stock_id" in df_copy.columns:
            df_copy = df_copy.sort_values(["stock_id", "week", "time"])
            df_copy["bucket"] = df_copy.groupby(["stock_id", "week"]).cumcount()
        elif "bucket" not in df_copy.columns:
            if "week" in df_copy.columns and "stock_id" in df_copy.columns:
                print("2")
                df_copy["bucket"] = df_copy.groupby(["stock_id", "week"]).cumcount()
            elif "stock_id" in df_copy.columns:
                print("3")
                df_copy["bucket"] = df_copy.groupby("stock_id").cumcount()
            else:
                raise ValueError(f"{model} lacks enough information for buckets.")

    if "stock_id" not in df_copy.columns:
        raise ValueError(f"{model} is missing the stock_id column.")

    df_copy["stock_id"] = df_copy["stock_id"].apply(lambda x: str(int(float(str(x)))))
    if "week" in df_copy.columns:
        df_copy["week"] = df_copy["week"].astype(int)
    else:
        df_copy["week"] = 0

    required = {"stock_id", "week", "bucket", "true", "pred"}
    missing = required - set(df_copy.columns)
    if missing:
        raise ValueError(f"{model} is missing columns: {', '.join(missing)}")

    if "cluster" not in df_copy.columns:
        df_copy["cluster"] = None

    return df_copy[list(required) + ["cluster"]]


model_dfs = {}
successfully_loaded_models = []

for model, path in model_files.items():
    try:
        raw = pd.read_csv(path)
        std = standardize_df(raw, model)
        std["model"] = model
        model_dfs[model] = std
        successfully_loaded_models.append(model)
    except FileNotFoundError:
        print("4")
    except ValueError:
        print("5")
    except Exception:
        print("6")

if not model_dfs:
    pn.pane.Alert("Error: No model data loaded.", alert_type="danger").servable()

if len(model_dfs) > 1:
    sets = [set(zip(df["stock_id"], df["week"])) for df in model_dfs.values() if not df.empty]
    common_pairs = set.intersection(*sets) if sets else set()
else:
    single_df = next(iter(model_dfs.values()))
    common_pairs = set(zip(single_df["stock_id"], single_df["week"]))

if common_pairs:
    full_df = pd.concat(
        [
            df[df[["stock_id", "week"]].apply(tuple, axis=1).isin(common_pairs)]
            for df in model_dfs.values()
        ],
        ignore_index=True,
    )
else:
    full_df = pd.concat(model_dfs.values(), ignore_index=True)

unique_stocks = sorted(full_df["stock_id"].unique()) if not full_df.empty else []
model_options = successfully_loaded_models if successfully_loaded_models else ["No available model"]

model_select = pn.widgets.Select(name="Model", options=model_options, value=model_options[0])
stock_select = pn.widgets.Select(name="Stock", options=unique_stocks)
week_select = pn.widgets.Select(name="Week", options=[])
controls = pn.Row(model_select, stock_select, week_select, align="center")


@pn.depends(stock_select.param.value, model_select.param.value, watch=True)
def update_weeks(stock, model):
    if not (stock and model):
        week_select.options = []
        week_select.value = None
        return
    wks = sorted(full_df[(full_df.stock_id == stock) & (full_df.model == model)]["week"].unique())
    week_select.options = wks
    week_select.value = wks[0] if wks else None


if unique_stocks:
    stock_select.value = unique_stocks[0]


@pn.depends(model=model_select.param.value, stock=stock_select.param.value, week=week_select.param.value)
def make_plot(model, stock, week):
    if not (model and stock and week is not None):
        return pn.pane.Alert(
            "Please select model, stock, and week.",
            alert_type="info",
            width=900,
            align="center",
        )
    try:
        week_int = int(week)
    except Exception:
        return pn.pane.Alert(
            f"Invalid week selection: {week}",
            alert_type="warning",
            width=900,
            align="center",
        )

    df_slice = full_df[
        (full_df.model == model) & (full_df.stock_id == stock) & (full_df.week == week_int)
    ]
    if df_slice.empty:
        return pn.pane.Alert("No data", alert_type="warning", width=900, align="center")

    y_cols = [c for c in ["true", "pred"] if df_slice[c].notna().any()]
    if not y_cols:
        return pn.pane.Alert("No drawable data", alert_type="warning", width=900, align="center")

    plot = df_slice.hvplot(
        x="bucket",
        y=y_cols,
        xlabel="Bucket",
        ylabel="Volatility",
        width=900,
        height=400,
        title=f"Model: {model} • Stock: {stock} • Week: {week_int}",
        legend="top_left",
        line_width=2,
        responsive=True,
    ).opts(tools=["pan", "box_zoom", "reset", "save"], active_tools=[], toolbar="right", shared_axes=False, framewise=True)

    cluster_html = ""
    eg_df = model_dfs.get("EGARCH Model")
    if eg_df is not None:
        row = eg_df[(eg_df["stock_id"] == stock) & (eg_df["week"] == week_int)]
        if not row.empty and "cluster" in row.columns:
            cluster_val = row["cluster"].iloc[0]
            cluster_html = (
                f"<div style='text-align:center;font-weight:bold;'>📌 Cluster {cluster_val}</div>"
            )

    return pn.Column(
        pn.Row(
            pn.Spacer(width=50),
            pn.Column(pn.pane.HoloViews(plot, sizing_mode="stretch_width"), sizing_mode="stretch_width"),
            pn.Spacer(width=125),
        ),
        pn.pane.HTML(cluster_html) if cluster_html else pn.Spacer(height=0),
    )


metrics_df_list = []
for name, path in metrics_files.items():
    try:
        dfm = pd.read_csv(path)
        dfm["model"] = name
        metrics_df_list.append(dfm)
    except Exception:
        print("7")

all_metrics_df = pd.concat(metrics_df_list, ignore_index=True) if metrics_df_list else pd.DataFrame()

aaa = "/Users/shiyuchen/Downloads/DATA3888_Optiver_9_GroupCode/EGARCH/stock_week_cluster_mapping.csv"
try:
    map_df = pd.read_csv(aaa)
    map_df["stock"] = map_df["stock_id"].astype(int)
    map_df["week"] = map_df["week"].astype(int)
    clusters = sorted(map_df["cluster"].unique())
except Exception:
    print("8")
    map_df = pd.DataFrame(columns=["stock", "week", "cluster"])
    clusters = []

metrics_model_sel = pn.widgets.Select(name="Metrics Model", options=list(metrics_files.keys()))
metrics_cluster_sel = pn.widgets.Select(name="Cluster", options=clusters)
metrics_controls = pn.Row(metrics_model_sel, metrics_cluster_sel, align="center")


@pn.depends(model=metrics_model_sel, cluster=metrics_cluster_sel)
def make_metrics_boxplot(model, cluster):
    if all_metrics_df.empty or map_df.empty:
        return pn.pane.Alert(" Data not fully loaded", alert_type="danger")

    sel = map_df[map_df.cluster == int(cluster)]
    pairs = set(zip(sel.stock, sel.week))
    dfm = all_metrics_df[
        (all_metrics_df.model == model)
        & all_metrics_df[["stock", "week"]].apply(tuple, axis=1).isin(pairs)
    ]

    if dfm.empty:
        return pn.pane.Alert(" No available metrics data", alert_type="warning")

    metric_cols = ["R2", "RMSE", "MAE", "MedAE", "MAPE(%)", "SMAPE(%)", "QLIKE"]
    plots = []
    for col in metric_cols:
        if dfm[col].notna().any():
            q1 = dfm[col].quantile(0.25)
            q3 = dfm[col].quantile(0.75)
            iqr = q3 - q1
            upper = q3 + 1.5 * iqr
            clean = dfm[dfm[col] <= upper]

            p = clean.hvplot.box(
                y=col, width=300, height=300, legend=False, title=col
            ).opts(
                tools=["pan", "box_zoom", "reset", "save"],
                active_tools=[],
                toolbar="right",
                shared_axes=False,
                framewise=True,
            )
            plots.append(p)

    if not plots:
        return pn.pane.Alert(" All metric columns are missing", alert_type="warning")

    rows = []
    for idx, i in enumerate(range(0, len(plots), 4)):
        subplots = [pn.pane.HoloViews(p) for p in plots[i : i + 4]]
        margin = 75 if idx == 0 else 225
        rows.append(pn.Row(pn.Spacer(width=margin), pn.Row(*subplots), pn.Spacer(width=margin)))

    title = pn.pane.Markdown(
        f"### 📊 {model} • Cluster {cluster} (n={len(dfm)})", align="center"
    )
    return pn.Column(title, *rows, sizing_mode="stretch_width")


header = pn.pane.HTML(
    """
    <h2 style='text-align:center;'> Stock Forecast Dashboard</h2>
    <p style='text-align:center;'>Data Display Panel</p>
    """,
    sizing_mode="stretch_width",
)

layout = pn.Column(
    header,
    controls,
    make_plot,
    pn.Spacer(height=40),
    pn.pane.Markdown("##  Model Metrics by Cluster", align="center"),
    metrics_controls,
    make_metrics_boxplot,
    align="center",
    sizing_mode="stretch_width",
    scroll=True,
)

layout.servable()
