void OnStart() {
    int totalBars = 4 * 24 * 365 * 5;

    MqlRates rates[];
    int copied = CopyRates(Symbol(), PERIOD_H1, 0, totalBars, rates);

    if (copied <= 0) {
        Print("Data fetch fail");
        return;
    }

    Print("bar count: ", copied);

    double tpDifferences[];
    double slDifferences[];
    int count = 0;

    for (int i = 0; i < copied; i++) {
        datetime t = rates[i].time;
        double open = rates[i].open;
        double high = rates[i].high;
        double low = rates[i].low;
        double close = rates[i].close;

        // ロンドン時間 (日本時間17:00〜01:00) のフィルタリング
        int hour = TimeHour(t);
        if (hour >= 17 || hour < 1) {
            double tpDiff = (close >= open) ? (high - open) : (open - low);
            double slDiff = (close >= open) ? (low - open) : (high - open);
            ArrayResize(tpDifferences, count + 1);
            ArrayResize(slDifferences, count + 1);
            tpDifferences[count] = tpDiff;
            slDifferences[count] = slDiff;
            count++;
        }
    }

    if (count == 0) {
        Print("ロンドン時間のデータがありません");
        return;
    }

    Print("tp: ");
    Print("avg: ", calcMean(tpDifferences, count));
    Print("med: ", calcMedian(tpDifferences, count));
    Print("sl: ");
    Print("avg: ", calcMean(slDifferences, count));
    Print("med: ", calcMedian(slDifferences, count));
}

int TimeHour(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
  }

double calcMean(double &differences[], int count){
    // 平均値（Mean）の計算
    double sum = 0;
    for (int i = 0; i < count; i++) {
        sum += differences[i];
    }
    return sum / count;

}

double calcMedian(double &differences[], int count) {
    // 中央値（Median）の計算
    ArraySort(differences);  // 昇順ソート
    return (count % 2 == 0) ? 
                    (differences[count / 2 - 1] + differences[count / 2]) / 2 :
                    differences[count / 2];

}
