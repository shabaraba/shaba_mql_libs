#include "FixedLotSizeManager.mqh";
#include "MonteCarloLotSizeManager.mqh";
#include "LotSizeManagerInterface.mqh";

enum CALC_LOT_SISE_TYPE {
  CALC_LOT_SIZE_TYPE_FIXED,
  CALC_LOT_SIZE_TYPE_MONTE_CARLO,
};

class LotSizeManagerFactory {
public:
  static LotSizeManager *create(CALC_LOT_SISE_TYPE type,
                                        const double initLot) {
    switch (type) {
    case CALC_LOT_SIZE_TYPE_FIXED:
      return new FixedLotSizeManager(initLot);
    case CALC_LOT_SIZE_TYPE_MONTE_CARLO:
      return new MonteCarloLotSizeManager(initLot);
    }
  return new FixedLotSizeManager(initLot);
  }
};
