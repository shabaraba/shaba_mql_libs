#include "LogicInterface.mqh"

class PerfectOrderLogic : public LogicInterface {
private:
  int maHandleList[]; // short term asc

public:
  PerfectOrderLogic(int &_maHandleList[]) {
    ArrayCopy(maHandleList, _maHandleList);
  }
  ENUM_LOGIC_RESULT execute() override {
    bool perfect_bull = true;
    bool perfect_bear = true;
    double tmp[1];
    CopyBuffer(maHandleList[0], 0, 1, 1, tmp);
    double currentMA = tmp[0];
    double shortTermMA;
    for (int i = 1; i < ArraySize(maHandleList); i++) {
      shortTermMA = currentMA;
      CopyBuffer(maHandleList[i], 0, 1, 1, tmp);
      currentMA = tmp[0];

      perfect_bull &= currentMA < shortTermMA;
      perfect_bear &= currentMA > shortTermMA;
    }
    return perfect_bull   ? LOGIC_RESULT_OPEN_LONG
           : perfect_bear ? LOGIC_RESULT_OPEN_SHORT
                          : LOGIC_RESULT_FLAT;
  }
};
