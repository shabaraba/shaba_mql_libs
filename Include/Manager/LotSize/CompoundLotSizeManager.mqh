#include "LotSizeManagerInterface.mqh"

class CompoundLotSizeManager : public LotSizeManager {
private:
  double lot;
  double base;

public:
  CompoundLotSizeManager(double _lot) {
    lot = _lot;
    base = 10000;
  };
  void wonThen() override {};
  void loseThen() override {};
  double get() override {
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    Print(lot * (int)(balance / base));
    return lot * (int)(balance / base);
  };
}
