#include "ExitLevelManagerInterface.mqh"

class FixedExitLevelManager : public ExitLevelManager {
private:
  double tp;
  double sl;

public:
  FixedExitLevelManager(double _initTp, double _initSl) {
    tp = _initTp;
    sl = _initSl;
  };
  void wonThen() override {};
  void loseThen() override {};

  double getTp(double price, ENUM_POSITION_TYPE type) override {
    return type == POSITION_TYPE_BUY ? price + tp : price - tp;
  };
  double getSl(double price, ENUM_POSITION_TYPE type) override {
    return type == POSITION_TYPE_BUY ? price - sl : price + sl;
  };
};
