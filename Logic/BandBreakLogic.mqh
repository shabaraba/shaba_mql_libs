#include "LogicInterface.mqh"

class BandBreakLogic : public LogicInterface {
private:
  int bandPeriod;
  double dev;
  int maHandleList[2]; // short term asc

  bool isCrossOver(double currentVal, double prevVal, double currentTh,
                   double prevTh) {
    return (prevVal <= prevTh && currentVal > currentTh);
  }
  bool isCrossUnder(double currentVal, double prevVal, double currentTh,
                    double prevTh) {
    return (prevVal >= prevTh && currentVal < currentTh);
  }

  void getBand(int shift, double &baseline, double &upperBand,
               double &lowerBand) {

    double ema25[1];
    int ema25Buffer = CopyBuffer(maHandleList[1], 0, 1, 1, ema25);
    baseline = ema25[0];
    double stdDev = CalcStdDev(bandPeriod, shift);
    upperBand = baseline + dev * stdDev;
    lowerBand = baseline - dev * stdDev;
  }

  // ─────────────────────────────
  //  補助関数：終値の標準偏差（対象：shift から period 本分）
  // ─────────────────────────────
  double CalcStdDev(int period, int shift) {
    double sum = 0.0, sumSq = 0.0;
    for (int i = shift; i < shift + period; i++) {
      double price = iClose(_Symbol, _Period, i);
      sum += price;
      sumSq += price * price;
    }
    double mean = sum / period;
    double variance = (sumSq / period) - (mean * mean);
    if (variance < 0)
      variance = 0;
    return MathSqrt(variance);
  }

public:
  BandBreakLogic(int &_maHandleList[], int _bandPeriod, double _dev) {
    ArrayCopy(maHandleList, _maHandleList);
    bandPeriod = _bandPeriod;
    dev = _dev;
  }
  ENUM_LOGIC_RESULT execute() override {
    double band_base, upperBand, lowerBand;
    double band_base_prev, upperBand_prev, lowerBand_prev;
    getBand(1, band_base, upperBand, lowerBand);
    getBand(2, band_base_prev, upperBand_prev, lowerBand_prev);

    double target[2];
    CopyBuffer(maHandleList[0], 0, 1, 2, target);
    double current = target[1];
    double prev = target[0];
    // エントリー条件：
    // ロングエントリー：パーフェクトオーダー（bull）かつ EMA10 が直前は下または
    // at バンド上、直近で上抜け（＝クロスオーバー） upperBand
    // ショートエントリー：パーフェクトオーダー（bear）かつ EMA10
    // が直前は上または at バンド下、直近で下抜け（＝クロスアンダー） lowerBand

    return isCrossOver(current, prev, upperBand, upperBand_prev)
               ? LOGIC_RESULT_OPEN_LONG
           : isCrossUnder(current, prev, lowerBand, lowerBand_prev)
               ? LOGIC_RESULT_OPEN_SHORT
           : isCrossUnder(current, prev, upperBand, upperBand_prev)
               ? LOGIC_RESULT_CLOSE_LONG
           : isCrossOver(current, prev, lowerBand, lowerBand_prev)
               ? LOGIC_RESULT_CLOSE_SHORT
               : LOGIC_RESULT_FLAT;
  }
};
