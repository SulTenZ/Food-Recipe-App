// resep_api/models/recipeModel.js
const mongoose = require('mongoose');


const recipeSchema = new mongoose.Schema({
  name: { 
    type: String,
    required: [true, 'Recipe name is required'],
    trim: true,
    minlength: [3, 'Name must be at least 3 characters long']
  },
  ingredients: { 
    type: [String],
    required: [true, 'At least one ingredient is required'],
    validate: {
      validator: function(v) {
        return v && v.length > 0;
      },
      message: 'Recipe must have at least one ingredient'
    }
  },
  instructions: { 
    type: String,
    required: [true, 'Cooking instructions are required'],
    minlength: [10, 'Instructions must be at least 10 characters long']
  },
  createdAt: { 
    type: Date,
    default: Date.now
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User ',
    required: true
  }
});

const Recipe = mongoose.model('Recipe', recipeSchema);

module.exports = Recipe;