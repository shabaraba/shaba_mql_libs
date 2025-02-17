#include "ExitLevelManagerInterface.mqh"

class NoneExitLevelManager : public ExitLevelManager {
public:
  void wonThen() override {};
  void loseThen() override {};

  double getTp(double price, ENUM_POSITION_TYPE type) override { return 0.0; };
  double getSl(double price, ENUM_POSITION_TYPE type) override { return 0.0; };
};
