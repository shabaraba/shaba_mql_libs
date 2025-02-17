#include "LotSizeManagerInterface.mqh"

class FixedLotSizeManager : public LotSizeManager {
private:
  double lot;

public:
  FixedLotSizeManager(double _lot) { lot = _lot; };
  void wonThen() override {};
  void loseThen() override {};
  double get() override { return lot; };
}
