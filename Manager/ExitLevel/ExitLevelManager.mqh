#include "ExitLevelManagerInterface.mqh"
#include "NoneExitLevelManager.mqh"
#include "FixedExitLevelManager.mqh"

enum EXIT_LEVEL_TYPE {
  EXIT_LEVEL_TYPE_NONE,
  EXIT_LEVEL_TYPE_FIXED,
};

class ExitLevelManagerFactory {
public:
  static ExitLevelManager *create(EXIT_LEVEL_TYPE type,
                                        const double initTp, const double initSl) {
    switch (type) {
    case EXIT_LEVEL_TYPE_NONE:
      return new NoneExitLevelManager();
    case EXIT_LEVEL_TYPE_FIXED:
      return new FixedExitLevelManager(initTp, initSl);
    }
  return new NoneExitLevelManager();
  }
};
