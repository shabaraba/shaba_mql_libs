#include "FixedLotSizeManager.mqh";
#include "LotSizeManagerInterface.mqh";

enum CALC_LOT_SISE_TYPE {
  CALC_LOT_SIZE_TYPE_FIXED,
  CALC_LOT_SIZE_TYPE_MONT,
};

class LotSizeManagerFactory {
public:
  static LotSizeManagerInterface *create(CALC_LOT_SISE_TYPE type,
                                        const double initLot) {
    switch (type) {
    case CALC_LOT_SIZE_TYPE_FIXED:
      return new FixedLotSizeManager(initLot);
    }
  return new FixedLotSizeManager(initLot);
  }
};
