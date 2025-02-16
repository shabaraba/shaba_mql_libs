#include "ExitLevelManagerInterface.mqh"

class FixedExitLevelManager : public ExitLevelManager{
private:
    double tp;
    double sl;
public:
    FixedExitLevelManager(double initTp, double initSl) {
        tp = initTp;
        sl = initSl;
    };
    void wonThen() override {};
    void loseThen() override {};
    double getTp() override {return tp;};
    double getSl() override {return sl;};
};
