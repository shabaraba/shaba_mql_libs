#include "ExitLevelManagerInterface.mqh"

class FixedExitLevelManager : public ExitLevelManager {
private:
  double point;
  double tp;
  double sl;

public:
  FixedExitLevelManager(string symbol, double _initTp, double _initSl) {
    tp = _initTp;
    sl = _initSl;
    point = SymbolInfoDouble(symbol, SYMBOL_POINT) * 10;
  };
  void wonThen() override {};
  void loseThen() override {};

  double getTp(double price, ENUM_POSITION_TYPE type) override {
    return type == POSITION_TYPE_BUY ? price + tp * point : price - tp * point;
  };
  double getSl(double price, ENUM_POSITION_TYPE type) override {
    return type == POSITION_TYPE_BUY ? price - sl * point : price + sl * point;
  };
};
