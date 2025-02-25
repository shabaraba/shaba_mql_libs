#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\Tree.mqh>

#property script_show_inputs

input int searchTerm = 5;
input double targetPercent = 70;
input int totalBars = 4 * 24 * 365 * 5;

class CMyTreeNode : public CTreeNode {
private:
  int m_value; // ノードに格納する値
  string m_path;

public:
  // コンストラクタ
  CMyTreeNode(int value, string path) {
    m_value = value;
    m_path = path;
  }

  // 値を取得するメソッド
  int Value() { return m_value; }
  void setValue(int v) { m_value = v; }
  string Path() const { return m_path; }
};

// 任意の深さの二分木を作成する関数
void CreateBinaryTree(CMyTreeNode *current, int depth, string path) {
  if (depth <= 0)
    return;

  CMyTreeNode *left = new CMyTreeNode(0, path + "bear ");
  CMyTreeNode *right = new CMyTreeNode(0, path + "bull ");
  current.Left(left);
  current.Right(right);
  CreateBinaryTree(left, depth - 1, path + "bear ");
  CreateBinaryTree(right, depth - 1, path + "bull ");
}

// 幅優先探索の実行
void BreadthFirstSearch(CTree &tree) {
  CMyTreeNode *root = dynamic_cast<CMyTreeNode *>(tree.Root());
  if (root == NULL) {
    Print("treee is empty");
    return;
  }

  // キューの初期化
  CArrayObj *queue = new CArrayObj();
  queue.Add(root);
  CMyTreeNode *currentNode = NULL;

  // 探索の実行
  while (queue.Total() > 0) {
    // キューからノードを取り出す
    currentNode = queue.Detach(0);
    if (currentNode == NULL) {
      printf("Detach error");
      delete queue;
      return;
    }

    // ノードのデータを処理（ここでは表示）
    CMyTreeNode *left = currentNode.Left();
    CMyTreeNode *right = currentNode.Right();
    if (left != NULL && right != NULL) {
      int leftValue = left.Value();
      int rightValue = right.Value();
      double leftPercent =
          leftValue == 0 ? 0
                         : (double)leftValue / (rightValue + leftValue) * 100.0;
      double rightPercent =
          rightValue == 0
              ? 0
              : (double)rightValue / (rightValue + leftValue) * 100.0;
      if (leftPercent > targetPercent) {
        Print(left.Path(), ": ", leftValue, ": ", leftPercent, "(%)");
      }
      if (rightPercent > targetPercent) {

        Print(right.Path(), ": ", rightValue, ": ", rightPercent, "(%)");
      }
    }

    // 左子が存在すればキューに追加
    if (currentNode.Left() != NULL)
      queue.Add(currentNode.Left());

    // 右子が存在すればキューに追加
    if (currentNode.Right() != NULL)
      queue.Add(currentNode.Right());
  }
  delete currentNode;
  delete queue;
}

// エントリーポイント
void OnStart() {
  int totalBars = 4 * 24 * 365 * 5;

  MqlRates rates[];
  int copied = CopyRates(Symbol(), PERIOD_H1, 0, totalBars, rates);

  if (copied <= 0) {
    Print("Data fetch fail");
    return;
  }

  Print("bar count: ", copied);

  // ツリーの初期化
  CTree tree;
  CMyTreeNode *root = new CMyTreeNode(0, "");
  tree.Insert(root);
  CreateBinaryTree(root, searchTerm, "");
  for (int i = searchTerm; i < copied; i++) {
    CMyTreeNode *current = root;
    for (int j = i - searchTerm; j < i; j++) {
      if (rates[j].close - rates[i].open > 0) {
        current = current.Right();
      } else {
        current = current.Left();
      }
      current.setValue(current.Value() + 1);
    }
  }
  BreadthFirstSearch(tree);
}

