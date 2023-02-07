#ifndef MY_HASH_SET
#define MY_HASH_SET
// This is a very simple hashset implmentation for small value/object buitlin
// type int long float ... Its main usage to check duplication.  It's two levels
// hash set. The hash set is class MyHashSet<KeyType, N_Size, Hash1, Hash2>
// KeyType is the hash key
// N_Size is the size level 2, the total bucket is N_size*127.
// Hash1  the first level hash object
// Hash2  the second level hash object
// NOTE::  It's better to use two different HASH algorithms for Hash1 and Hash2
#include <array>
#include <bitset>
#include <unordered_set>
template <class T, std::size_t N, class Hash = std::hash<T>> class MyHashNode {

public:

  void insert(const T &v) {
    size_t hashslot = hash(v) % N;
    if (bits.test(hashslot) && ntable[hashslot] != v) {
      auxtable.insert(v);
    } else {
      ntable[hashslot] = v;
      bits.set(hashslot);
    }
  }


  bool find(const T &v) {
    size_t hashslot = hash(v) % N;
    if (!bits.test(hashslot))
      return false;
    if (ntable[hashslot] == v)
      return true;
    return (auxtable.find(v) != auxtable.end());
  }



  void clear() {
    bits.reset();
    auxtable.clear();
  }

private:
  std::array<T, N> ntable;
  std::bitset<N> bits;
  std::unordered_set<T> auxtable;
  Hash hash;
};

template <class T, std::size_t N, class Hash1 = std::hash<T>,
          class Hash2 = std::hash<T>>
class MyHashSet {
public:


  void insert(const T &v) {
    size_t hashslot = hash(v) % 127;
    table[hashslot].insert(v);
  }



  bool find(const T &v) {
    size_t hashslot = hash(v) % 127;
    return table[hashslot].find(v);
  }


  
  void clear() {
    for (int i = 0; i < 127; i++)
      table[i].clear();
  }

private:
  std::array<MyHashNode<T, N, Hash2>, 127> table;
  Hash1 hash;
};
#endif
