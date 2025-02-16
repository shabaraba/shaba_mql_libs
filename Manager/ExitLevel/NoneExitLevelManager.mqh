#include "ExitLevelManagerInterface.mqh"

class NoneExitLevelManager : public ExitLevelManager {
public:
  void wonThen() override {};
  void loseThen() override {};
  double getTp() override { return 0.0; };
  double getSl() override { return 0.0; };
};
