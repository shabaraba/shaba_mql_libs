#include "CompoundLotSizeManager.mqh";
#include "FixedLotSizeManager.mqh";
#include "LotSizeManagerInterface.mqh";
#include "MonteCarloLotSizeManager.mqh";

enum CALC_LOT_SISE_TYPE {
  CALC_LOT_SIZE_TYPE_FIXED,
  CALC_LOT_SIZE_TYPE_MONTE_CARLO,
  CALC_LOT_SIZE_TYPE_COMPOUND,
};

class LotSizeManagerFactory {
public:
  static LotSizeManager *create(CALC_LOT_SISE_TYPE type, const double initLot) {
    switch (type) {
    case CALC_LOT_SIZE_TYPE_FIXED:
      return new FixedLotSizeManager(initLot);
    case CALC_LOT_SIZE_TYPE_MONTE_CARLO:
      return new MonteCarloLotSizeManager(initLot);
    case CALC_LOT_SIZE_TYPE_COMPOUND:
      return new CompoundLotSizeManager(initLot);
    }
    return new FixedLotSizeManager(initLot);
  }
};
