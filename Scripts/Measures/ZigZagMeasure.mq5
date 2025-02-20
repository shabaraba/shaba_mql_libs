//+------------------------------------------------------------------+
//| ZigZag の波の平均幅を求めるスクリプト                            |
//+------------------------------------------------------------------+
#property script_show_inputs

input int depth = 12;       // ZigZagのDepthパラメータ
input int deviation = 5;    // ZigZagのDeviationパラメータ
input int backstep = 3;     // ZigZagのBackstepパラメータ
input int maxBars = 5000;    // 計算するバーの数

void OnStart()
{
    // ZigZagインジケーターのハンドルを作成
    int zigzagHandle = iCustom(Symbol(), 0, "Examples/ZigZag", depth, deviation, backstep);
    if (zigzagHandle == INVALID_HANDLE) {
        Print("ZigZag インジケーターの取得に失敗しました。");
        return;
    }
    
    // バッファの準備
    double zigzagBuffer[];
    ArrayResize(zigzagBuffer, maxBars);

    // インジケーターバッファを取得
    if (!CopyBuffer(zigzagHandle, 0, 0, maxBars, zigzagBuffer)) {
        Print("ZigZag データの取得に失敗しました。");
        return;
    }

    int lastPeakIndex = -1;
    double lastPeakValue = 0;
    double totalRange = 0;
    double data[];
    int count = 0;

    // 高値・安値の変化を検出して幅を計算
    for (int i = maxBars - 1; i >= 0; i--) {
        if (zigzagBuffer[i] != 0) { // 0 以外の値はZigZagのポイント
            if (lastPeakIndex != -1) {
                double range = MathAbs(zigzagBuffer[i] - lastPeakValue);
                ArrayResize(data, ArraySize(data)+1);
                data[ArraySize(data)-1] = range;
                totalRange += range;
                count++;
            }
            lastPeakIndex = i;
            lastPeakValue = zigzagBuffer[i];
        }
    }

    // 平均値を算出
    double avg = calcMean(data, count);
    double med = calcMedian(data, count);

    Print("ZigZag");
    Print("avg: ", avg, " pips (", (avg / _Point / 10), ")");
    Print("med: ", med, " pips (", med / _Point / 10, ")");
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
