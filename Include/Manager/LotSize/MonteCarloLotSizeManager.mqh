#include "LotSizeManagerInterface.mqh"

class MonteCarloLotSizeManager : public LotSizeManager {
private:
  double initLot;
  int current;
  int sequence[];

  void resetSequence() {
    int tmp[2] = {0, 1};
    ArrayResize(sequence, 2);
    ArrayCopy(sequence, tmp);
    current = 1;
  }

public:
  MonteCarloLotSizeManager(double _lot) {
    initLot = _lot;
    current = 1;
    resetSequence();
  };
  void wonThen() override {
    ArrayRemove(sequence, 0, 1);
    ArrayRemove(sequence, ArraySize(sequence) - 1, 1);
    if (ArraySize(sequence) == 0) {
      resetSequence();
    } else if (ArraySize(sequence) == 1) {
      int divided = sequence[0] / 2;
      int mod = sequence[0] % 2;
      int tmp[2] = {divided, divided + mod};
      ArrayCopy(sequence, tmp);
    }
    current = sequence[0] + sequence[ArraySize(sequence) - 1];
  };
  void loseThen() override {
    ArrayResize(sequence, ArraySize(sequence) + 1);
    sequence[ArraySize(sequence) - 1] = current;
    current = sequence[0] + sequence[ArraySize(sequence) - 1];
    if (current > 50) {
      resetSequence();
    }
  };
  double get() override {
    ArrayPrint(sequence);
    return current * initLot;
  };
}
