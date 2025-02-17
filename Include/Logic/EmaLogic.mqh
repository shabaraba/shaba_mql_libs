#include "LogicInterface.mqh"

class EmaLogic : public LogicInterface {
private:
  int maHandle;

public:
  EmaLogic(int _maHandle) {
        maHandle = _maHandle;
  }

  ENUM_LOGIC_RESULT execute() override {
    double tmp[2];
    CopyBuffer(maHandle, 0, 1, 2, tmp);
    return tmp[0] < tmp[1] ? LOGIC_RESULT_OPEN_LONG : LOGIC_RESULT_OPEN_SHORT;
  }
};
