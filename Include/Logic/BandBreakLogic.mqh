#include "LogicInterface.mqh"
class BandBreakLogic : public LogicInterface {
private:
  int targethandle;
  int bbHandle;
  int bandPeriod;
  double dev;
  int maHandleList[2]; // short term asc

  bool isCrossOver(double &target[], double &line[]) {
    return (target[0] <= line[0] && target[1] > line[1]);
  }
  bool isCrossUnder(double &target[], double &line[]) {
    return (target[0] >= line[0] && target[1] < line[0]);
  }

public:
  BandBreakLogic(int _targetHandle, int _bbHandle) {
    targethandle = _targetHandle;
    bbHandle = _bbHandle;
  }

  ENUM_LOGIC_RESULT execute() override {
    double target[];
    double upper[];
    double lower[];
    CopyBuffer(targethandle, 0, 1, 2, target);
    CopyBuffer(bbHandle, 1, 1, 2, upper);
    CopyBuffer(bbHandle, 2, 1, 2, lower);

    // エントリー条件：
    // ロングエントリー：パーフェクトオーダー（bull）かつ EMA10 が直前は下または
    // at バンド上、直近で上抜け（＝クロスオーバー） upperBand
    // ショートエントリー：パーフェクトオーダー（bear）かつ EMA10
    // が直前は上または at バンド下、直近で下抜け（＝クロスアンダー） lowerBand

    return isCrossOver(target, upper)
               ? LOGIC_RESULT_OPEN_LONG
           : isCrossUnder(target, lower)
               ? LOGIC_RESULT_OPEN_SHORT
           : isCrossUnder(target, upper)
               ? LOGIC_RESULT_CLOSE_LONG
           : isCrossOver(target, lower)
               ? LOGIC_RESULT_CLOSE_SHORT
               : LOGIC_RESULT_FLAT;
  }
};
