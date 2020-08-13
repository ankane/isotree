require_relative "test_helper"

class IsoTreeTest < Minitest::Test
  def test_hashes
    data = test_data
    model = IsoTree::IsolationForest.new(ntrees: 10, ndim: 3, nthreads: 1)
    model.fit(data)
    predictions = model.predict(data)
    # different results on different platforms with same seed
    expected =
      if mac?
        [0.4617110810516882, 0.5210998270463041, 0.5661097222304904]
      else
        [0.4980166082320242, 0.43188267587261414, 0.5831027020603062]
      end
    assert_elements_in_delta expected, predictions.first(3)
    assert_equal 100, predictions.each_with_index.max[1]
  end

  def test_array
    data = numeric_data
    model = IsoTree::IsolationForest.new(ntrees: 10, ndim: 3, nthreads: 1)
    model.fit(data)
    predictions = model.predict(data)
    # different results on different platforms with same seed
    expected =
      if mac?
        [0.510724008530721, 0.4338067195010562, 0.5569583231648105]
      else
        [0.4980166082320242, 0.43188267587261414, 0.5831027020603062]
      end
    assert_elements_in_delta expected, predictions.first(3)
    assert_equal 100, predictions.each_with_index.max[1]
  end

  def test_numo
    data = Numo::DFloat.cast(numeric_data)
    model = IsoTree::IsolationForest.new(ntrees: 10, ndim: 3, nthreads: 1)
    model.fit(data)
    predictions = model.predict(data)
    # different results on different platforms with same seed
    expected =
      if mac?
        [0.510724008530721, 0.4338067195010562, 0.5569583231648105]
      else
        [0.4980166082320242, 0.43188267587261414, 0.5831027020603062]
      end
    assert_elements_in_delta expected, predictions.first(3)
    assert_equal 100, predictions.each_with_index.max[1]
  end

  def test_rover
    require "rover"

    data = Rover::DataFrame.new(test_data)
    model = IsoTree::IsolationForest.new(ntrees: 10, ndim: 3, nthreads: 1)
    model.fit(data)
    predictions = model.predict(data)
    # different results on different platforms with same seed
    expected =
      if mac?
        [0.4617110810516882, 0.5210998270463041, 0.5661097222304904]
      else
        [0.4980166082320242, 0.43188267587261414, 0.5831027020603062]
      end
    assert_elements_in_delta expected, predictions.first(3)
    assert_equal 100, predictions.each_with_index.max[1]
  end

  def test_predict_output_avg_depth
    data = test_data
    model = IsoTree::IsolationForest.new(ntrees: 10, ndim: 3, nthreads: 1)
    model.fit(data)
    predictions = model.predict(data, output: "avg_depth")
    # different results on different platforms with same seed
    expected =
      if mac?
        [9.359408405715701, 7.893975468975469, 6.890641859762501]
      else
        [] # todo
      end
    assert_elements_in_delta expected, predictions.first(3)
    assert_equal 100, predictions.each_with_index.min[1]
  end

  def test_not_fit
    model = IsoTree::IsolationForest.new
    error = assert_raises do
      model.predict([])
    end
    assert_equal "Not fit", error.message
  end

  def test_different_columns
    x = Numo::DFloat.new(101, 2).rand_norm
    model = IsoTree::IsolationForest.new
    model.fit(x)
    error = assert_raises(ArgumentError) do
      model.predict(x.reshape(2, 101))
    end
    assert_equal "Input must have 2 columns for this model", error.message
  end

  def test_no_data
    model = IsoTree::IsolationForest.new
    error = assert_raises(ArgumentError) do
      model.fit([])
    end
    assert_equal "No data", error.message
  end

  def test_bad_size
    model = IsoTree::IsolationForest.new
    error = assert_raises(ArgumentError) do
      model.fit([[1, 2], [3]])
    end
    assert_equal "All rows must have the same number of columns", error.message
  end

  def test_bad_dimensions
    model = IsoTree::IsolationForest.new
    error = assert_raises(ArgumentError) do
      model.fit(Numo::DFloat.cast([[[1]]]))
    end
    assert_equal "Input must have 2 dimensions", error.message
  end

  def test_data
    CSV.table("test/support/data.csv").map(&:to_h)
  end

  def numeric_data
    test_data.map { |v| [v[:num1], v[:num2]] }
  end

  def mac?
    RbConfig::CONFIG["host_os"] =~ /darwin/i
  end
end
