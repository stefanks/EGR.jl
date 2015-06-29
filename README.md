# EGR-Julia

[![Build Status](https://travis-ci.org/stefanks/EGR.jl.svg?branch=master)](https://travis-ci.org/stefanks/EGR.jl)
[![Coverage Status](https://coveralls.io/repos/stefanks/EGR.jl/badge.svg)](https://coveralls.io/r/stefanks/EGR.jl)

The Stochastic Gradient (SG) algorithm is a popular learning algorithm for machine learning. Its main drawback is the high variance of the gradient estimates. In this evolving gradient framework, past history is used to reduce the variance of the SG step direction. 

Efficient implementations of gradients for Multi-Class logistic regression, and sparse binary logistic regression are used.