(ns columns
  (:use input))

(def heights [36 24 12])

(defn height
  "Calculates the height of the collection"
  [categories]
  (reduce
    +
    (map
      (fn [category]
        (+
          (nth heights (:level category))
          (height (:children category))))
      (if (map? categories) (vector categories) categories))))


(defn with-levels
  "Returns the collection with added level info"
  ([categories] (with-levels categories 0))
  ([categories level]
    (map
      (fn [category]
        (assoc category
          :level level
          :children (with-levels (:children category) (+ level 1))))
      categories)))


(defn min-height-index
  "Returns the index of column (collection) with the smallest height"
  [columns]
  (let [heights (map height columns)]
    (.indexOf heights (apply min heights))))


(defn initial-columns
  "Returns a collection with specified number of nested collections. E.g. (initial-columns 3) -> [[] [] []]"
  [number-of-columns]
  (vec (take number-of-columns (cycle [[]]))))


(defn sorted-columns
  "Returns sorted data by columns with nearly equal heights"
  [number-of-columns categories]
  (reduce
    (fn [columns category]
      (update-in columns [(min-height-index columns)] conj category))
    (initial-columns number-of-columns) categories))


(println (sorted-columns 3 (reverse (sort-by height (with-levels data)))))

; How to run this crap:
;  $ brew install clj
;  $ clj columns.clj
